require_relative '../../puppet_x/consul/tls_parameters'

Puppet::Type.newtype(:consul_key_value) do
  desc <<-EOD
  Manage a consul key value object.
  EOD
  PuppetX::Consul::TLSParameters.apply(self)

  ensurable

  newparam(:name, namevar: true) do
    desc 'Name of the key/value object'
    validate do |value|
      raise ArgumentError, 'Key/value object name must be a string' unless value.is_a?(String)
    end
  end

  newparam(:flags) do
    desc 'Flags integer'
    validate do |value|
      raise ArgumentError, 'The flags value must be an integer' unless value.is_a?(Integer)
    end
    defaultto 0
  end

  newproperty(:value) do
    desc 'The key value string'
    validate do |value|
      raise ArgumentError, 'The key value must be a string' unless value.is_a?(String)
    end
  end

  newparam(:acl_api_token) do
    desc 'Token for accessing the ACL API'
    validate do |value|
      raise ArgumentError, 'ACL API token must be a string' unless value.is_a?(String)
    end
    defaultto 'anonymous'
  end

  newparam(:datacenter) do
    desc 'Name of the datacenter to query. If unspecified, the query will default to the datacenter of the Consul agent at the HTTP address.'
    validate do |value|
      raise ArgumentError, 'Datacenter must be a string' unless value.is_a?(String)
    end
    defaultto ''
  end

  newparam(:protocol) do
    desc 'consul protocol'
    newvalues(:http, :https)
    defaultto :http
  end

  newparam(:ca_file, parent: PuppetX::Consul::TLSParameters::Path) do
    desc 'Absolute path to a PEM CA bundle used to verify the Consul HTTPS server.'
  end

  newparam(:ca_path, parent: PuppetX::Consul::TLSParameters::Path) do
    desc 'Absolute path to an OpenSSL hashed CA directory used to verify the Consul HTTPS server.'
  end

  newparam(:client_cert, parent: PuppetX::Consul::TLSParameters::Path) do
    desc 'Absolute path to a PEM client certificate, optionally followed by intermediate certificates, for mutual TLS.'
  end

  newparam(:client_key, parent: PuppetX::Consul::TLSParameters::Path) do
    desc 'Absolute path to the unencrypted PEM private key for client_cert.'
  end

  newparam(:port) do
    desc 'consul port'
    defaultto 8500
    validate do |value|
      raise ArgumentError, 'The port number must be a number' unless value.is_a?(Integer)
    end
  end

  newparam(:hostname) do
    desc 'consul hostname'
    validate do |value|
      raise ArgumentError, 'The hostname must be a string' unless value.is_a?(String)
    end
    defaultto 'localhost'
  end

  newparam(:api_tries) do
    desc 'number of tries when contacting the Consul REST API'
    defaultto 3
    validate do |value|
      raise ArgumentError, 'Number of API tries must be a number' unless value.is_a?(Integer)
    end
  end

  autorequire(:service) do
    ['consul']
  end
end
