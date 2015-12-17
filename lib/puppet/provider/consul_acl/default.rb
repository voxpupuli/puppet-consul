require 'json'
require 'net/http'
require 'uri'
Puppet::Type.type(:consul_acl).provide(
  :default
) do
  mk_resource_methods

  def self.list_resources(acl_api_token)
    if @acls
      return @acls
    end

    # this might be configurable by searching /etc/consul.d
    # but would break for anyone using nonstandard paths
    uri = URI("http://localhost:#{:port}/v1/acl")
    http = Net::HTTP.new(uri.host, uri.port)

    path=uri.request_uri + "/list?token=#{acl_api_token}"
    req = Net::HTTP::Get.new(path)
    res = http.request(req)

    if res.code == '200'
      acls = JSON.parse(res.body)
    else
      raise(Puppet::Error,"Cannot retrieve ACLs: invalid return code #{res.code} uri: #{path} body: #{req.body}")
    end

    nacls = acls.collect do |acl|
      if !acl['Rules'].empty?
        { :name   => acl["Name"],
             :type   => acl["Type"],
             :rules  => JSON.parse(acl["Rules"]),
             :id     => acl["ID"],
             :ensure => :present}
      else
        { :name   => acl["Name"],
             :type   => acl["Type"],
             :rules  => {},
             :id     => acl["ID"],
             :ensure => :present}
      end
    end

    @acls = nacls
    nacls
  end

  def put_acl(method,body)
    uri = URI("http://localhost:#{:port}/v1/acl")
    http = Net::HTTP.new(uri.host, uri.port)
    acl_api_token = @resource[:acl_api_token]
    path = uri.request_uri + "/#{method}?token=#{acl_api_token}"
    req = Net::HTTP::Put.new(path)
    if body
      req.body = body.to_json
    end
    res = http.request(req)
    if res.code != '200'
      raise(Puppet::Error,"Session #{name} create: invalid return code #{res.code} uri: #{path} body: #{req.body}")
    end
  end

  def get_resource_id(name)
    acl_api_token = @resource[:acl_api_token]
    resources = self.class.list_resources(acl_api_token).select do |res|
      res[:name] == name
    end
    # if the user creates multiple with the same name this will do odd things
    if resources.first
        return resources.first[:id]
    else
        return nil
    end
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
    if @resource[:rules]
      rules = @resource[:rules].to_json
    else
      rules = ""
    end
    type = @resource[:type]
    id = @resource[:id]
    if id
      if @property_flush[:ensure] == :absent
        put_acl("destroy/#{id}", nil)
        return
      end
      put_acl('update', { "id"    => "#{id}",
                          "name"  => "#{name}",
                          "type"  => "#{type}",
                          "rules" => "#{rules}" })

    else
      put_acl('create', { "id"    => "#{id}",
                          "name"  => "#{name}",
                          "type"  => "#{type}",
                          "rules" => "#{rules}" })
    end
  end
end
