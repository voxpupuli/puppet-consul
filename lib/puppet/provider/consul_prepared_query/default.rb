require 'json'
require 'net/http'
require 'uri'
Puppet::Type.type(:consul_prepared_query).provide(
  :default
) do
  mk_resource_methods

  def self.prefetch(resources)
    resources.each do |name, resource|
      Puppet.debug("prefetching for #{name}")
      port = resource[:port]
      hostname = resource[:hostname]
      protocol = resource[:protocol]
      token = resource[:acl_api_token]
      tries = resource[:api_tries]

      found_prepared_queries = list_resources(token, port, hostname, protocol, tries).select do |prepared_query|
        prepared_query[:name] == name
      end

      found_prepared_query = found_prepared_queries.first || nil
      if found_prepared_query
        Puppet.debug("found #{found_prepared_query}")
        resource.provider = new(found_prepared_query)
      else
        Puppet.debug("found none #{name}")
        resource.provider = new({ ensure: :absent })
      end
    end
  end

  def self.list_resources(acl_api_token, port, hostname, protocol, tries)
    return @prepared_queries if @prepared_queries

    # this might be configurable by searching /etc/consul.d
    # but would break for anyone using nonstandard paths
    uri = URI("#{protocol}://#{hostname}:#{port}/v1/query")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.instance_of? URI::HTTPS

    path = uri.request_uri + "?token=#{acl_api_token}"
    req = Net::HTTP::Get.new(path)
    res = nil

    # retry Consul API query for ACLs, in case Consul has just started
    (1..tries).each do |i|
      unless i == 1
        Puppet.debug("retrying Consul API query in #{i} seconds")
        sleep i
      end
      res = http.request(req)
      break if res.code == '200'
    end

    if res.code == '200'
      prepared_queries = JSON.parse(res.body)
    else
      Puppet.warning("Cannot retrieve prepared_queries: invalid return code #{res.code} uri: #{path} body: #{req.body}")
      return {}
    end

    nprepared_queries = prepared_queries.collect do |prepared_query|
      {
        name: prepared_query['Name'],
        id: prepared_query['ID'],
        session: prepared_query['Session'],
        token: prepared_query['Token'],
        service: prepared_query['Service'],
        dns: prepared_query['DNS'],
        ensure: :present,
      }
    end

    @prepared_queries = nprepared_queries
    nprepared_queries
  end

  def get_path(id)
    idstr = id ? "/#{id}" : ''
    uri = URI("#{@resource[:protocol]}://#{@resource[:hostname]}:#{@resource[:port]}/v1/query#{idstr}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.instance_of? URI::HTTPS
    acl_api_token = @resource[:acl_api_token]
    [uri.request_uri + "?token=#{acl_api_token}", http]
  end

  def create_prepared_query(body)
    path, http = get_path(false)
    req = Net::HTTP::Post.new(path)
    req.body = body.to_json if body
    res = http.request(req)
    raise(Puppet::Error, "Session #{name} create: invalid return code #{res.code} uri: #{path} body: #{req.body}") if res.code != '200'
  end

  def update_prepared_query(id, body)
    path, http = get_path(id)
    req = Net::HTTP::Put.new(path)
    if body
      body[:id] = id
      req.body = body.to_json
    end
    res = http.request(req)
    raise(Puppet::Error, "Session #{name} update: invalid return code #{res.code} uri: #{path} body: #{req.body}") if res.code != '200'
  end

  def delete_prepared_query(id)
    path, http = get_path(id)
    req = Net::HTTP::Delete.new(path)
    res = http.request(req)
    raise(Puppet::Error, "Session #{name} delete: invalid return code #{res.code} uri: #{path} body: #{req.body}") if res.code != '200'
  end

  def get_resource(name, port, hostname, protocol, tries)
    acl_api_token = @resource[:acl_api_token]
    resources = self.class.list_resources(acl_api_token, port, hostname, protocol, tries).select do |res|
      res[:name] == name
    end
    # if the user creates multiple with the same name this will do odd things
    resources.first || nil
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def flush
    name = @resource[:name]
    token = @resource[:token]
    service_name = @resource[:service_name]
    service_near = @resource[:service_near]
    service_failover_n = @resource[:service_failover_n]
    service_failover_dcs = @resource[:service_failover_dcs]
    service_only_passing = @resource[:service_only_passing]
    service_tags = @resource[:service_tags]
    node_meta = @resource[:node_meta]
    service_meta = @resource[:service_meta]
    ttl = @resource[:ttl]
    port = @resource[:port]
    hostname = @resource[:hostname]
    protocol = @resource[:protocol]
    tries = @resource[:api_tries]
    template = @resource[:template]
    template_regexp = @resource[:template_regexp]
    template_type = @resource[:template_type]
    prepared_query = get_resource(name, port, hostname, protocol, tries)
    query_data = {
      'Name' => name.to_s,
      'Token' => token.to_s,
      'Service' => {
        'Service' => service_name.to_s,
        'Near' => service_near.to_s,
        'Failover' => {
          'NearestN' => service_failover_n,
          'Datacenters' => service_failover_dcs,
        },
        'OnlyPassing' => service_only_passing,
        'Tags' => service_tags,
        'NodeMeta' => node_meta,
        'ServiceMeta' => service_meta
      },
      'DNS' => {
        'TTL' => "#{ttl}s"
      }
    }
    if template
      query_data['Template'] = {
        'Type' => template_type,
        'Regexp' => template_regexp,
      }
    end
    if prepared_query
      id = prepared_query[:id]
      if @property_flush[:ensure] == :absent
        delete_prepared_query(id)
        return
      end
      update_prepared_query(id, query_data)

    else
      create_prepared_query(query_data)
    end
    @property_hash.clear
  end
end
