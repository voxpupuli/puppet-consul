require 'json'
require 'net/http'
require 'uri'
require 'base64'
Puppet::Type.type(:consul_key_value).provide(
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

      found_key_values = list_resources(token, port, hostname, protocol, tries).select do |key_value|
        key_value[:name] == name
      end

      found_key_value = found_key_values.first || nil
      if found_key_value
        Puppet.debug("found #{found_key_value}")
        resource.provider = new(found_key_value)
      else
        Puppet.debug("found none #{name}")
        resource.provider = new({:ensure => :absent})
      end
    end
  end

  def self.list_resources(acl_api_token, port, hostname, protocol, tries)
    if @key_values
      return @key_values
    end

    # this might be configurable by searching /etc/consul.d
    # but would break for anyone using nonstandard paths
    uri = URI("#{protocol}://#{hostname}:#{port}/v1/kv/?recurse")
    http = Net::HTTP.new(uri.host, uri.port)

    path=uri.request_uri + "&token=#{acl_api_token}"
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
      key_values = JSON.parse(res.body)

    # No keys exists yet in this datacenter
    elsif res.code == '404'
      return []
    else
      Puppet.warning("Cannot retrieve key_values: invalid return code #{res.code} uri: #{path} body: #{req.body}")
      return {}
    end

    nkey_values = key_values.collect do |key_value|
      {
        :name    => key_value["Key"],
        :value   => (key_value["Value"] == nil ? '' : Base64.decode64(key_value["Value"])),
        :flags   => Integer(key_value["Flags"]),
        :ensure  => :present,
      }
    end
    @key_values = nkey_values
    nkey_values
  end

  def get_path(name)
    uri = URI("#{@resource[:protocol]}://#{@resource[:hostname]}:#{@resource[:port]}/v1/kv/#{name}")
    http = Net::HTTP.new(uri.host, uri.port)
    acl_api_token = @resource[:acl_api_token]
    return uri.request_uri + "?token=#{acl_api_token}", http
  end

  def create_or_update_key_value(name, value, flags)
    path, http = get_path(name)
    req = Net::HTTP::Put.new(path + "&flags=#{flags}")
    req.body = value
    res = http.request(req)
    if res.code != '200'
      raise(Puppet::Error,"Session #{name} create/update: invalid return code #{res.code} uri: #{path} body: #{req.body}")
    end
  end

  def delete_key_value(name)
    path, http = get_path(name)
    req = Net::HTTP::Delete.new(path)
    res = http.request(req)
    if res.code != '200'
      raise(Puppet::Error,"Session #{name} delete: invalid return code #{res.code} uri: #{path} body: #{req.body}")
    end
  end

  def get_resource(name, port, hostname, protocol, tries)
    acl_api_token = @resource[:acl_api_token]
    resources = self.class.list_resources(acl_api_token, port, hostname, protocol, tries).select do |res|
      res[:name] == name
    end
    # if the user creates multiple with the same name this will do odd things
    resources.first || nil
  end

  def initialize(value={})
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
    flags = @resource[:flags]
    value = @resource[:value]
    port = @resource[:port]
    hostname = @resource[:hostname]
    protocol = @resource[:protocol]
    tries = @resource[:api_tries]
    key_value = self.get_resource(name, port, hostname, protocol, tries)
    if key_value
      if @property_flush[:ensure] == :absent
        delete_key_value(name)
        return
      end
      create_or_update_key_value(name, value, flags)

    else
      create_or_update_key_value(name, value, flags)
    end
    @property_hash.clear
  end
end
