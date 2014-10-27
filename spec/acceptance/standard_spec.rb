require 'spec_helper_acceptance'

describe 'consul class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors based on the example' do
      pp = <<-EOS
        class { 'consul':
          config_hash => {
              'datacenter' => 'east-aws',
              'data_dir'   => '/opt/consul',
              'log_level'  => 'INFO',
              'node_name'  => 'foobar',
              'server'     => true
          }
        }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe file('/opt/consul') do
      it { should be_directory }
    end

    describe service('consul') do
      it { should be_enabled }
    end

    describe command('consul version') do
      it { should return_stdout /Consul v0\.4\.1/ }
    end

  end
end
