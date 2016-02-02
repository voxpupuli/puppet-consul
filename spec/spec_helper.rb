require 'puppetlabs_spec_helper/module_spec_helper'
require 'hiera-puppet-helper/rspec'
require 'hiera'
require 'puppet/indirector/hiera'

# config hiera to work with let(:hiera_data)
def hiera_stub
  config = Hiera::Config.load(hiera_config)
  config[:logger] = 'puppet'
  Hiera.new(:config => config)
end

RSpec.configure do |c|
  c.mock_framework = :rspec
  c.before(:each) do
    allow(Puppet::Indirector::Hiera).to receive(:hiera) { hiera_stub }
  end

end
