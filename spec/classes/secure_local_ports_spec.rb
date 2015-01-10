require 'spec_helper'

describe 'consul::secure_local_ports' do

  context 'with defaults' do

    it 'should contain default resources' do
      should contain_firewall('001consul_allow_root').with({
        'chain'       => 'OUTPUT',
        'action'      => 'accept',
        'destination' => '127.0.0.1',
        'proto'       => 'tcp',
        'dport'       => ['8300', '8400', '8500'],
        'uid'         => '0',
      })
      should contain_firewall('002consul_allow_consul').with({
        'chain'       => 'OUTPUT',
        'action'      => 'accept',
        'destination' => '127.0.0.1',
        'proto'       => 'tcp',
        'dport'       => ['8300', '8400', '8500'],
        'uid'         => 'consul',
      })
      should contain_firewall('999consul_drop').with({
        'chain'       => 'OUTPUT',
        'action'      => 'drop',
        'destination' => '127.0.0.1',
        'proto'       => 'tcp',
        'dport'       => ['8300', '8400', '8500'],

      })
    end
  end
end
