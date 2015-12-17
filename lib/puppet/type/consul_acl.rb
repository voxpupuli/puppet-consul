Puppet::Type.newtype(:consul_acl) do

  desc <<-'EOD'
  Manage a consul token and its ACLs.
  EOD
  ensurable

  newparam(:name, :namevar => true) do
    desc 'Name of the token'
    validate do |value|
      raise ArgumentError, "ACL name must be a string" if not value.is_a?(String)
    end
  end

  newproperty(:type) do
    desc 'Type of token'
    newvalues('client', 'management')
    defaultto 'client'
  end

  newproperty(:acl_api_token) do
    desc 'Token for accessing the ACL API'
    validate do |value|
      raise ArgumentError, "ACL API token must be a string" if not value.is_a?(String)
    end
    defaultto ''
  end

  newproperty(:rules) do
    desc 'hash of ACL rules for this token'
    defaultto {}
    validate do |value|
      raise ArgumentError, "ACL rules must be provided as a hash" if not value.is_a?(Hash)
    end
  end

  newproperty(:id) do
    desc 'ID of token'
  end

  newproperty(:port) do
    desc 'consul port'
    value = 8500 if value.nil?
    validate do |value|
      raise ArgumentError, "The port number must be a number" if not value.is_a?(Integer)
    end
  end

  autorequire(:service) do
    ['consul']
  end
end
