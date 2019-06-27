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
  context 'with performance options' do
    it 'should work with no errors based on the example' do
      pp = <<-EOS
        package { 'unzip': ensure => present } ->
        class { 'consul':
          version        => '1.2.3',
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
      its(:stdout) { should match %r{Consul v1.2.3} }
    end
  end
  context 'with new ACL system' do
    acl_master_token = '222bf65c-2477-4003-8f8e-842a4b394d8d'

    it 'should work with no errors based on the example' do
      pp = <<-EOS
        package { 'unzip': ensure => present } ->
        class { 'consul':
          version        => '1.5.0',
          manage_service => true,
          config_hash    => {
              'datacenter'         => 'east-aws',
              'primary_datacenter' => 'east-aws',
              'data_dir'           => '/opt/consul',
              'log_level'          => 'INFO',
              'node_name'          => 'foobar',
              'server'             => true,
              'bootstrap'          => true,
              'bootstrap_expect'   => 1,
              'start_join'         => ['127.0.0.1'],
              'rejoin_after_leave' => true,
              'leave_on_terminate' => true,
              'client_addr'        => "0.0.0.0",
              'acl' => {
                'enabled'        => true,
                'default_policy' => 'allow',
                'down_policy'    => 'extend-cache',
                'tokens'         => {
                  'master' => '#{acl_master_token}'
                }
              },
          },
          acl_api_token    => '#{acl_master_token}',
          acl_api_hostname => '127.0.0.1',
          acl_api_tries    => 10,
          tokens => {
            'test_token_xyz' => {
              'accessor_id'      => '7c4e3f11-786d-44e6-ac1d-b99546a1ccbd',
              'policies_by_name' => ['test_policy_abc']
            },
            'test_token_absent' => {
              'accessor_id'      => '10381ad3-2837-43a6-b1ea-e27b7d53a749',
              'policies_by_name' => ['test_policy_abc'],
              'ensure'           => 'absent'
            }
          },
          policies => {
            'test_policy_abc' => {
              'description' => "This is a test policy",
              'rules'       => [
                {'resource' => 'service_prefix', 'segment' => 'tst_service', 'disposition' => 'read'},
                {'resource' => 'key', 'segment' => 'test_key', 'disposition' => 'write'},
                {'resource' => 'node_prefix', 'segment' => '', 'disposition' => 'deny'},
                {'resource' => 'operator', 'disposition' => 'read'},
              ],
            },
            'test_policy_absent' => {
              'description' => "This policy should not exists",
              'rules'       => [
                {'resource' => 'service_prefix', 'segment' => 'test_segment', 'disposition' => 'read'}
              ],
              'ensure'      => 'absent'
            }
          }
        }
      EOS

      # Run it twice to test for idempotency
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
      its(:stdout) { should match %r{Consul v1.5.0} }
    end

    describe command("consul acl token list --token #{acl_master_token} | grep Description") do
      its(:stdout) { should match %r{test_token_xyz} }
    end

    describe command("consul acl token list --token #{acl_master_token} | grep -v Local | grep -v Create | grep -v Legacy | sed s/'.* - '//g") do
      its(:stdout) { should include "test_token_xyz\nPolicies:\ntest_policy_abc" }
    end

    describe command("consul acl policy read --name test_policy_abc --token #{acl_master_token}") do
      its(:stdout) { should include "Rules:\nservice_prefix \"tst_service\" {\n  policy = \"read\"\n}\n\nkey \"test_key\" {\n  policy = \"write\"\n}\n\nnode_prefix \"\" {\n  policy = \"deny\"\n}" }
    end
  end
end
