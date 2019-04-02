Puppet::Type.newtype(:consul_policy) do

  desc <<-'EOD'
  Manages a Consul ACL policy
  EOD
  ensurable

  newparam(:name, :namevar => true) do
    desc 'Name of the policy'
    validate do |value|
      raise ArgumentError, "Policy name must be a string" if not value.is_a?(String)
    end
  end

  newparam(:id) do
    desc 'ID of already existing policy'
    validate do |value|
      raise ArgumentError, "ID must be a string" if not value.is_a?(String)
    end

    defaultto ''
  end

  newparam(:description) do
    desc 'Description of the policy'
    validate do |value|
      raise ArgumentError, "Description must be a string" if not value.is_a?(String)
    end
  end

  newparam(:rules) do
    desc 'List of ACL rules for this policy'
    defaultto []
  end

  newparam(:acl_api_token) do
    desc 'Token for accessing the ACL API'
    validate do |value|
      raise ArgumentError, "ACL API token must be a string" if not value.is_a?(String)
    end
    defaultto ''
  end

  newproperty(:protocol) do
    desc 'consul protocol'
    newvalues(:http, :https)
    defaultto :http
  end

  newparam(:port) do
    desc 'consul port'
    defaultto 8500
    validate do |value|
      raise ArgumentError, "The port number must be a number" if not value.is_a?(Integer)
    end
  end

  newparam(:hostname) do
    desc 'consul hostname'
    validate do |value|
      raise ArgumentError, "The hostname must be a string" if not value.is_a?(String)
    end
    defaultto 'localhost'
  end

  newparam(:api_tries) do
    desc 'number of tries when contacting the Consul REST API'
    defaultto 3
    validate do |value|
      raise ArgumentError, "Number of API tries must be a number" if not value.is_a?(Integer)
    end
  end

  autorequire(:service) do
    ['consul']
  end
end
