require 'net/http'
require 'uri'
require 'puppet/provider/consulbase'
require 'puppet_x/consul/consul'

Puppet::Type.type(:consul_key_value).provide(
  :default, :parent => Puppet::Provider::ConsulBase
) do
  mk_resource_methods

  def self.get_cache_key(opts = {})
    port = opts[:port]
    hostname = opts[:hostname]
    protocol = opts[:protocol]
    token = opts[:acl_api_token]
    tries = opts[:api_tries]
    datacenter = opts[:datacenter]
    "#{token}#{port}#{hostname}#{protocol}#{tries}#{datacenter}"
  end

  # Fetches a list of resources on the system.
  # returns a list of Hashes
  def self.fetch_resources(opts = {})
    # this might be configurable by searching /etc/consul.d
    # but would break for anyone using nonstandard paths

    # TODO: extract library options from type
    client_opts = {}
    client_opts[:use_ssl] = (opts[:protocol] == :https)
    client_opts[:retry_period] = opts[:retry_period]

    consulclient = PuppetX::Consul::Consul.new(opts[:hostname], opts[:acl_api_token], opts[:port], client_opts)

    key_values = consulclient.get_kv('/', 'recurse' => true, 'dc' => opts[:datacenter])
    return [] if key_values.nil?

    nkey_values = key_values.collect do |kv|
      val = process_single_remote_resource(kv)
      val
    end
    nkey_values
  end

  def self.process_single_remote_resource(key_value)
    {
      :name     => key_value['Key'],
      :value    => key_value['Value'] || '',
      :flags    => Integer(key_value['Flags']),
      :ensure   => :present
    }
  end

  def get_client
    if defined?(@client).nil?
      # TODO: extract library options from type
      client_opts = {}
      client_opts[:use_ssl] = (@resource[:protocol] == :https)
      client_opts[:retry_period] = @resource[:retry_period]

      @client = PuppetX::Consul::Consul.new(@resource[:hostname], @resource[:acl_api_token], @resource[:port], client_opts)
    end
    @client
  end

  def create_remote_resource
    consul_client = get_client

    path = "/v1/kv/#{name}"
    body = @resource[:value]
    consul_client.put(path, body, :dc => @resource[:datacenter], :flags => @resource[:flags])
  end

  def update_remote_resource(remote_resource)
    consul_client = get_client

    path = "/v1/kv/#{remote_resource[:name]}"
    body = @resource[:value]
    consul_client.put(path, body, :dc => @resource[:datacenter], :flags => @resource[:flags])
  end

  def delete_remote_resource(remote_resource)
    consul_client = get_client

    path = "/v1/kv/#{remote_resource[:name]}"
    consul_client.delete(path, nil, :dc => @resource[:datacenter])
  end

  def remote_requires_update?(remote_resource)
    return true if @resource[:value] != remote_resource[:value]
    return true if @resource[:flags] != remote_resource[:flags]
    false
  end
end
