require 'spec_helper_acceptance'

describe 'consul class' do

  context 'default parameters' do
    apply_manifest_opts = {
      :catch_failures => true,
      :debug          => true,
    }
    it 'should work with no errors based on the example' do
      pp = <<-EOS
        package { 'zip': ensure => present } ->
        # Don't manage the service as it doesn't work well in docker
        class { 'consul':
          version        => '0.6.4',
          manage_service => false,
          config_hash    => {
              'datacenter' => 'east-aws',
              'data_dir'   => '/opt/consul',
              'ui_dir'     => '/opt/consul/ui',
              'log_level'  => 'INFO',
              'node_name'  => 'foobar',
              'server'     => true,
          }
        }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp, apply_manifest_opts).exit_code).to_not eq(1)
      expect(apply_manifest(pp, apply_manifest_opts).exit_code).to eq(0)
    end

    describe file('/opt/consul') do
      it { should be_directory }
    end

    describe file('/opt/consul/ui') do
      it { should be_linked_to '/opt/consul/archives/consul-0.6.4_web_ui' }
    end

    describe service('consul') do
      it { should be_enabled }
    end

    describe command('consul version') do
      its(:stdout) { should match /Consul v0\.6\.4/ }
    end

  end
end
