require 'puppetlabs_spec_helper/module_spec_helper'
require 'webmock/rspec'
require 'rspec-puppet-facts'
include RspecPuppetFacts

WebMock.disable_net_connect!()

add_custom_fact :ipaddress_lo, '127.0.0.1'
add_custom_fact :facterversion, Facter.version

RSpec.configure do |c|
  c.mock_framework = :rspec
end
