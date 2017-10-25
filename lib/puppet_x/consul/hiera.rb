require 'pathname'
require Pathname.new(__FILE__).dirname.expand_path
require 'puppet_x/consul/consul'
require 'puppet_x/consul/cache'

require 'cgi'

# PupppetX::Consul::Hiera implements all logic for the hiera_consul backend.
module PuppetX::Consul::Hiera
  def self.lookup_key(key, options, context)
    unless confined_to_keys(key, options)
      context.explain { 'Skipping consul backend because key does not match confine_to_keys' }
      context.not_found
      return
    end

    cache ||= PuppetX::Consul::Cache.new(options['cache_dir'])
    cache_key = get_cache_key(key, options)

    uri, key_replaced, recurse = process_path(key, options)

    data = nil?
    if context.cache_has_key(uri.path)
      data = context.cached_value(uri.path)
    else

      exceptions = [Timeout ]

      if RUBY_VERSION > '2.0'
        #pre ruby 2.0 does not have the OpenTimeout exception.
        exceptions << Net::OpenTimeout
      end

      begin
        data, idx = key_value_lookup(key, uri, options, context)

        # update the caches.
        context.cache(cache_key, data)
        cache.store_cache(cache_key, idx, data)
      rescue PuppetX::Consul::ConsulValueError
        raise Puppet::DataBinding::LookupError, "hiera_consul failed could not parse #{options['document']} document for key: #{key} on uri: #{options['uri']}"
      rescue Puppet::Error => exc
        Puppet.warning("hiera-consul: Could not reach consul: #{exc}")
        cache_key = get_cache_key(key, options)
        data = cache.retrieve_cache(cache_key)
        raise exc if data.nil?
        context.cache(cache_key, data)
      rescue *exceptions => exc
        Puppet.warning("hiera-consul: Could not reach consul: #{exc}")
        cache_key = get_cache_key(key, options)
        data = cache.retrieve_cache(cache_key)
        raise Puppet::Error, exc.to_s if data.nil?
        context.cache(cache_key, data)
      end
    end

    if data.nil? || data.empty?
      context.explain { "no data found for #{key} on #{uri}" }
      context.not_found
      return
    end

    if recurse
      # Recursive lookup, build hash
      process_recursive_result(key, uri.path, data)
    else
      # Literal lookup, should have only one result.
      if data.size != 1
        raise Puppet::DataBinding::LookupError, "hiera_consul failed got multiple entries for key: #{key} on uri: #{options['uri']}"
      end
      process_literal_result(data[0]['Value'], key, key_replaced)
    end
  end

  # process_literal_result takes a value and determines
  # how best to process it.
  # The rules in order:
  # 1. If we used __KEY__ in the path, then return the value as is.
  # 2. If it is a Hash (was either json or yaml), return value[key] if it exists.
  # 3. return not_found
  def self.process_literal_result(value, key, key_replaced)
    # if __KEY__ was in the path, we just return the value of the key.
    return value if key_replaced
    # else we will lookup `key` in the data before returning.
    if value.is_a?(Hash)
      # For paths like /Common where the key is not in the path.
      # we can only return data if the document decodes into a hash.
      return value[key] if value.key?(key)
    end

    context.explain { "no data found for #{key} on #{options['uri']}" }
    context.not_found
  end

  # process_path takes the key and uri (from options)
  # and prepares it for use by the consul client.
  # This means:
  # - convert the uri string into a URI object
  # - replace __KEY__ if necessary
  # - report back on the __KEY__ replacement and if its recursive.
  def self.process_path(key, options)
    key_replaced = options['uri'].include? '__KEY__'
    uri = URI.parse(options['uri'])

    unless uri.path.start_with?('/v1/kv/')
      raise ArgumentError, "only key value lookups are supported. path should start with `/v1/kv/`: #{path}"
    end

    uri.path.sub! %r{v1/kv/}, ''
    uri.path.gsub! '__KEY__', key

    recurse = !uri.query.nil? && uri.query.include?('recurse')
    [uri, key_replaced, recurse]
  end

  # key_value_lookup calls the consul client and leverages the cache
  # in context, to avoid making the same api call multiple times during
  # the same catalog compilation.
  def self.key_value_lookup(_key, uri, options, _context)
    # deconstruct real_uri into arguments for the consul library.
    # uri = URI.parse(options['uri'])
    host = uri.host
    port = uri.port
    path = uri.path

    consul_options = create_option_hash(options)
    client = PuppetX::Consul::Consul.new(host, '', port, consul_options)

    par = {}
    par = CGI.parse(uri.query) unless uri.query.nil?

    return client.get_kv(path, recurse: par.key?('recurse'), dc: par.fetch('dc', nil))
  end

  def self.create_option_hash(options)
    option_keys = [:document, :tries, :retry_period, :read_timeout, :connect_timeout,
                   :use_ssl, :ssl_verify, :ssl_ca_cert, :ssl_cert, :ssl_key, :use_auth,
                   :auth_pass, :auth_user]

    lookup_params = {}
    options.each do |k, v|
      lookup_params[k.to_sym] = v if option_keys.include?(k.to_sym)
    end
    lookup_params
  end

  # confined_to_keys checks if the configuration allows the lookup of this key.
  # @param key being queried
  # @param options Configuration data
  # @return [Boolean] true if lookup can proceed
  # @raise ArgumentError if configuration data is wrong.
  #
  # Based on work from Craig Dunn https://github.com/crayfishx/hiera-http
  def self.confined_to_keys(key, options)
    if confine_keys = options['confine_to_keys']
      raise ArgumentError, 'confine_to_keys must be an array' unless confine_keys.is_a?(Array)

      confine_keys.map! { |r| Regexp.new(r) }
      regex_key_match = Regexp.union(confine_keys)
      return false unless key[regex_key_match] == key
      return true
    end
    true
  end

  # Merge multiple key/value entries into a single document.
  # Do note that when a folder also contains a value, the value is ignored.
  def self.process_recursive_result(_key, kvpath, data)
    result_hash = {}
    data.each do |el|
      path = el['Key'].split('/')

      # If the searched kvpath is /bar/foo
      # then we will remove this from the Key before
      # using it to build a single document.
      # Example:
      # kvpath=/bar/foo
      # Key: /bar/foo/abc  => abc
      # Key: /bar/foo/xyz  => xyz
      # Key: /bar/foo2     => foo2
      # Key: /bar/foo3/avx => foo3/avx
      # while kvpath_el.first == path.first
      #   puts "#{kvpath_el.first}|#{path.first}"
      #   path.shift
      #   kvpath_el.shift
      # end

      temp_hash = result_hash
      path.each_index do |idx|
        pel = path[idx]
        if idx < (path.size - 1) # all elements except the last
          temp_hash[pel] = {} unless temp_hash.key?(pel)
          temp_hash = temp_hash[pel]
          next
        end
        # Set the value when on the last element of the path
        # if it does not yet exist
        temp_hash[pel] = el['Value'] unless temp_hash.key?(pel)
      end
    end

    kvpath_el = kvpath.split('/')
    kvpath_el.each do |el|
      break if result_hash.keys.size != 1

      result_top_key = result_hash.keys.first
      result_hash = result_hash[el] if el == result_top_key
    end
    result_hash
  end

  def self.get_cache_key(key, options)
    "#{key}:#{options['uri']}:#{options['token']}"
  end
end
