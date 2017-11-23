require 'puppetlabs_spec_helper/module_spec_helper'
require 'webmock/rspec'

WebMock.disable_net_connect!()

RSpec.configure do |c|
  c.mock_framework = :rspec
  c.default_facts = {
    :architecture           => 'x86_64',
    :operatingsystem        => 'Ubuntu',
    :osfamily               => 'Debian',
    :operatingsystemrelease => '14.04',
    :os                     => {
      'family'  => 'Debian',
    },
    :kernel                 => 'Linux',
    :ipaddress_lo           => '127.0.0.1',
    :consul_version         => 'unknown',
  }
end
