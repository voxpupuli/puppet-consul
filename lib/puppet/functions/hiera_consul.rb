$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))
require 'puppet_x/consul/hiera'

Puppet::Functions.create_function(:hiera_consul) do
  dispatch :lookup_key do
    param 'Variant[String, Numeric]', :key
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  def lookup_key(key, options, context)
    PuppetX::Consul::Hiera.lookup_key(key, options, context)
  end
end
