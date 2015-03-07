require 'json'
require 'net/http'
require 'uri'
Puppet::Type.type(:consul_acl).provide(
  :default
) do
  mk_resource_methods

  def self.instances
    acls = list_resources
    acls.collect do |acl|
      new(acl)
    end
  end

  def self.list_resources
    if @acls
      return @acls
    end

    # this might be configurable by searching /etc/consul.d
    # but would break for anyone using nonstandard paths
    uri = URI('http://localhost:8500/v1/acl')
    http = Net::HTTP.new(uri.host, uri.port)

    path=uri.request_uri + '/list'
    req = Net::HTTP::Get.new(path)
    res = http.request(req)

    if res.code == '200'
      acls = JSON.parse(res.body)
    else
      acls = []
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

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def put_acl(method,body)
    uri = URI('http://localhost:8500/v1/acl')
    http = Net::HTTP.new(uri.host, uri.port)
    path = uri.request_uri + "/#{method}"
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
    resources = self.class.list_resources.select do |res|
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
    id = self.get_resource_id(name)
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
      put_acl('create', { "name"  => "#{name}",
                          "type"  => "#{type}",
                          "rules" => "#{rules}" })
    end
  end
end
