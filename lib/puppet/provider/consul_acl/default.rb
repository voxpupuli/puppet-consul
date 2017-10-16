require 'json'
require 'net/http'
require 'pp'
require 'uri'
require 'puppet/provider/consulbase'
require 'puppet_x/consul/consul'

Puppet::Type.type(:consul_acl).provide(
  :default, :parent => Puppet::Provider::ConsulBase
) do
  mk_resource_methods

  def self.get_cache_key(opts = {})
    port = opts[:port]
    hostname = opts[:hostname]
    protocol = opts[:protocol]
    token = opts[:acl_api_token]
    tries = opts[:api_tries].to_s
    "#{token}#{port}#{hostname}#{protocol}#{tries}"
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
    acls = consulclient.get_safe('/v1/acl/list')

    nacls = acls.collect do |item|
      val = process_single_remote_resource(item)
      val
    end
    nacls
  end

  def self.process_single_remote_resource(acl)
    {
      :name   => acl['Name'],
      :type   => acl['Type'].intern,
      :rules  => acl['Rules'].empty? ? {} : JSON.parse(acl['Rules']),
      :id     => acl['ID'],
      :ensure => :present
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

    path = '/v1/acl/create'
    body = fetch_api_resource_body
    consul_client.put(path, body, {})
  end

  def update_remote_resource(remote_resource)
    consul_client = get_client

    path = '/v1/acl/update'
    body = fetch_api_resource_body(remote_resource[:id])

    consul_client.put(path, body, {})
  end

  def delete_remote_resource(remote_resource)
    consul_client = get_client

    path = "/v1/acl/destroy/#{remote_resource[:id]}"

    consul_client.put(path, nil, {})
  end

  def remote_requires_update?(remote_resource)
    return true if @resource[:type] != remote_resource[:type]
    return true if @resource[:rules] != remote_resource[:rules]
    false
  end

  def fetch_api_resource_body(id = '')
    name = @resource[:name]
    rules = @resource[:rules]
    type = @resource[:type]

    rules_json = ''
    rules_json = @resource[:rules].to_json if @resource[:rules]

    res = {}
    res = { 'ID' => id } unless id == ''
    res = res.merge!('Name' => name.to_s,
                     'Type'  => type.to_s,
                     'Rules' => rules_json.to_s)
    res
  end
end
