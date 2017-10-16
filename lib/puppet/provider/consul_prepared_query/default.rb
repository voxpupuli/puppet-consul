require 'puppet/provider/consulbase'
require 'puppet_x/consul/consul'

Puppet::Type.type(:consul_prepared_query).provide(
  :default, :parent => Puppet::Provider::ConsulBase
) do
  mk_resource_methods

  def self.get_cache_key(opts = {})
    port = opts[:port]
    hostname = opts[:hostname]
    protocol = opts[:protocol]
    token = opts[:acl_api_token]
    tries = opts[:api_tries]
    "#{token}#{port}#{hostname}#{protocol}#{tries}"
  end

  # Fetches a list of optss on the system.
  # returns a list of Hashes
  def self.fetch_resources(opts = {})
    # this might be configurable by searching /etc/consul.d
    # but would break for anyone using nonstandard paths

    # TODO: extract library options from type
    client_opts = {}
    client_opts[:use_ssl] = (opts[:protocol] == :https)
    client_opts[:retry_period] = opts[:retry_period]

    consulclient = PuppetX::Consul::Consul.new(opts[:hostname], opts[:acl_api_token], opts[:port], client_opts)

    prepared_queries = consulclient.get_safe('/v1/query')

    nprepared_queries = prepared_queries.collect do |prepared_query|
      val = process_single_remote_resource(prepared_query)
      val
    end
    nprepared_queries
  end

  def self.process_single_remote_resource(prepared_query)
    # make sure we can use brackets for nested lookups
    service = prepared_query.fetch('Service', {})
    dns = prepared_query.fetch('DNS', {})
    template = prepared_query.fetch('Template', {})
    failover = service.fetch('Failover', {})

    # all the default values for this type are empty strings
    prepared_query.default = ''
    service.default = ''
    dns.default = ''
    template.default = ''
    failover.default = ''

    # convert the TTL to an Integer
    ttl = dns['TTL'].delete('s').to_i

    {
      :ensure               => :present,
      :name                 => prepared_query['Name'],
      :token                => prepared_query['Token'],
      :id                   => prepared_query['ID'],
      :service_name         => service['Service'],
      :service_near         => service['Near'],
      :service_failover_n   => failover['NearestN'],
      :service_failover_dcs => failover['Datacenters'],
      :service_only_passing => service['OnlyPassing'],
      :service_tags         => service['Tags'],
      :ttl                  => ttl,
      :template_regexp      => template['Regexp'],
      :template_type        => template['Type']
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

    path = '/v1/query'
    body = fetch_api_resource_body
    consul_client.post(path, body)
  end

  def update_remote_resource(remote_resource)
    consul_client = get_client

    path = "/v1/query/#{remote_resource[:id]}"
    body = fetch_api_resource_body(remote_resource[:id])
    consul_client.put(path, body)
  end

  def delete_remote_resource(remote_resource)
    consul_client = get_client

    path = "/v1/query/#{remote_resource[:id]}"
    body = fetch_api_resource_body(remote_resource[:id])
    consul_client.delete(path, body)
  end

  def remote_requires_update?(remote_resource)
    compare_elements = [:token, :service_name, :service_near,
                        :service_failover_n, :service_failover_dcs,
                        :service_only_passing, :service_tags, :ttl,
                        :template_type, :template_regexp]

    currently_is = remote_resource.select { |key, _value| compare_elements.include?(key) }
    should_be = {}
    # compare the current state and desired state for each parameter
    # return true if one of them is wrong.
    compare_elements.each do |el|
      # should_be[el] = self.send(el)
      should_be[el] = @resource[el]
      should_be[el] = '' if should_be[el] == :absent
    end

    unless @resource[:template]
      # make sure that default of the type, does not
      # mess up the comparison with the remote state
      should_be[:template_type] = ''
    end
    should_be != currently_is
  end

  def fetch_api_resource_body(id = '')
    name = @resource[:name]
    token = @resource[:token]
    service_name = @resource[:service_name]
    service_near = @resource[:service_near]
    service_failover_n = @resource[:service_failover_n]
    service_failover_dcs = @resource[:service_failover_dcs]
    service_only_passing = @resource[:service_only_passing]
    service_tags = @resource[:service_tags]
    ttl = @resource[:ttl]
    template = @resource[:template]
    template_regexp = @resource[:template_regexp]
    template_type = @resource[:template_type]

    query_data = {
      'Name'    => name.to_s,
      'Token'   => token.to_s,
      'Service' => {
        'Service'     => service_name.to_s,
        'Near'        => service_near.to_s,
        'Failover'    => {
          'NearestN'    => service_failover_n,
          'Datacenters' => service_failover_dcs
        },
        'OnlyPassing' => service_only_passing,
        'Tags'        => service_tags
      },
      'DNS' => {
        'TTL' => "#{ttl}s"
      }
    }
    if template
      query_data['Template'] = {
        'Type' => template_type,
        'Regexp' => template_regexp
      }
    end
    query_data['ID'] = id if id != ''
    query_data
  end
end
