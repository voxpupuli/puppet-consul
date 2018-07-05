require 'spec_helper_acceptance'

describe 'consul class' do

  context 'default parameters' do
    it 'should work with no errors based on the example' do
      pp = <<-EOS
        package { 'unzip': ensure => present } ->
        class { 'consul':
          version        => '1.0.5',
          manage_service => true,
          config_hash    => {
              'data_dir'   => '/opt/consul',
              'datacenter' => 'east-aws',
              'node_name'  => 'foobar',
              'server'     => true,
          }
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/opt/consul') do
      it { should be_directory }
    end

    describe service('consul') do
      it { should be_enabled }
      it { should be_running }
    end

    describe command('consul version') do
      its(:stdout) { should match %r{Consul v1.0.5} }
    end

  end
  context 'default parameters' do
    it 'should work with no errors based on the example' do
      pp = <<-EOS
        package { 'unzip': ensure => present } ->
        class { 'consul':
          version        => '1.1.0',
          manage_service => true,
          config_hash    => {
              'datacenter' => 'east-aws',
              'data_dir'   => '/opt/consul',
              'log_level'  => 'INFO',
              'node_name'  => 'foobar',
              'server'     => true,
          }
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/opt/consul') do
      it { should be_directory }
    end

    describe service('consul') do
      it { should be_enabled }
      it { should be_running }
    end

    describe command('consul version') do
      its(:stdout) { should match %r{Consul v1.1.0} }
    end

  end
  context 'with performance options' do
    it 'should work with no errors based on the example' do
      pp = <<-EOS
        package { 'unzip': ensure => present } ->
        class { 'consul':
          version        => '1.2.0',
          manage_service => true,
          config_hash    => {
              'datacenter'  => 'east-aws',
              'data_dir'    => '/opt/consul',
              'log_level'   => 'INFO',
              'node_name'   => 'foobar',
              'server'      => true,
              'performance' => {
                'raft_multiplier' => 2,
              },
          }
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/opt/consul') do
      it { should be_directory }
    end

    describe service('consul') do
      it { should be_enabled }
      it { should be_running }
    end

    describe command('consul version') do
      its(:stdout) { should match %r{Consul v1.2.0} }
    end

  end
end
