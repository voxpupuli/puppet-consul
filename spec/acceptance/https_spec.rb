require 'spec_helper_acceptance'
require 'json'
require_relative '../support/consul_tls'

describe 'Consul HTTPS API with a private CA' do
  include ConsulTLS

  def https_manifest(certificates, service_port: 8080, value: 'initial value')
    certificate_resources = certificates.map do |filename, content|
      <<~PUPPET
        file { '/etc/consul-https-pki/#{filename}':
          ensure  => file,
          owner   => 'consul',
          group   => 'consul',
          mode    => '0600',
          content => Sensitive(#{content.to_json}),
          require => File['/etc/consul-https-pki'],
          before  => Class['consul::run_service'],
        }
      PUPPET
    end.join

    <<~PUPPET
      package { ['unzip', 'curl']: ensure => present }
      -> class { 'consul':
        version                   => '1.20.0',
        manage_service            => true,
        manage_user_home_location => false,
        config_dir                => '/etc/consul-https-test',
        config_hash               => {
          'data_dir'         => '/opt/consul-https-test',
          'datacenter'       => 'https-test',
          'node_name'        => 'https-test',
          'bind_addr'        => '127.0.0.1',
          'client_addr'      => '127.0.0.1',
          'server'           => true,
          'bootstrap_expect' => 1,
          'ports'            => { 'http' => -1, 'https' => 8501 },
          'tls'              => {
            'https' => {
              'ca_file'         => '/etc/consul-https-pki/ca.pem',
              'cert_file'       => '/etc/consul-https-pki/server.pem',
              'key_file'        => '/etc/consul-https-pki/server-key.pem',
              'verify_incoming' => true,
            },
          },
          'acl' => {
            'enabled'        => true,
            'default_policy' => 'deny',
            'tokens'         => { 'initial_management' => 'https-test-management-token' },
          },
        },
        acl_api_protocol    => 'https',
        acl_api_hostname    => 'localhost',
        acl_api_port        => 8501,
        acl_api_token       => 'https-test-management-token',
        acl_api_tries       => 10,
        acl_api_ca_file     => '/etc/consul-https-pki/ca.pem',
        acl_api_client_cert => '/etc/consul-https-pki/client.pem',
        acl_api_client_key  => '/etc/consul-https-pki/client-key.pem',
        policies => {
          'https-test-policy' => {
            'rules' => [{ 'resource' => 'key_prefix', 'segment' => 'https-test/', 'disposition' => 'write' }],
          },
        },
        tokens => {
          'https-test-token' => {
            'accessor_id'      => '89a3e8d4-a137-4f6b-aabb-000000000001',
            'secret_id'        => '89a3e8d4-a137-4f6b-aabb-000000000002',
            'policies_by_name' => ['https-test-policy'],
          },
        },
        services => {
          'https-test-service' => { 'port' => #{service_port} },
        },
      }
      file { '/etc/consul-https-pki':
        ensure => directory,
        owner  => 'consul',
        group  => 'consul',
        mode   => '0700',
      }
      #{certificate_resources}
      Consul_policy['https-test-policy'] -> Consul_token['https-test-token']
      consul_key_value { 'https-test/value':
        ensure        => present,
        value         => #{value.to_json},
        protocol      => 'https',
        hostname      => 'localhost',
        port          => 8501,
        acl_api_token => '89a3e8d4-a137-4f6b-aabb-000000000002',
        api_tries     => 3,
        ca_file       => '/etc/consul-https-pki/ca.pem',
        client_cert   => '/etc/consul-https-pki/client.pem',
        client_key    => '/etc/consul-https-pki/client-key.pem',
        require       => Consul_token['https-test-token'],
      }
    PUPPET
  end

  def https_get(path, ca_file: 'ca.pem', client: true, hostname: 'localhost')
    credentials = client ? '--cert /etc/consul-https-pki/client.pem --key /etc/consul-https-pki/client-key.pem' : ''
    "curl --silent --show-error --fail --max-time 10 --cacert /etc/consul-https-pki/#{ca_file} #{credentials} " \
      "-H 'X-Consul-Token: https-test-management-token' https://#{hostname}:8501/v1/#{path}"
  end

  it 'manages API resources, verifies certificates and reloads services idempotently over mTLS' do
    ca = issue_certificate('Acceptance CA', authority: true)
    server = issue_certificate('localhost', issuer: ca, san: 'DNS:localhost', usage: 'serverAuth')
    client = issue_certificate('Puppet acceptance', issuer: ca, usage: 'clientAuth')
    wrong_ca = issue_certificate('Untrusted CA', authority: true)
    certificates = {
      'ca.pem' => ca[:cert].to_pem, 'server.pem' => server[:cert].to_pem, 'server-key.pem' => server[:key].to_pem,
      'client.pem' => client[:cert].to_pem, 'client-key.pem' => client[:key].to_pem, 'wrong-ca.pem' => wrong_ca[:cert].to_pem,
    }

    # Stop any agent left by the other acceptance scenarios before changing its data directory.
    on(default, 'if systemctl cat consul >/dev/null 2>&1; then systemctl stop consul; fi')
    manifest = https_manifest(certificates)
    apply_manifest(manifest, catch_failures: true)
    apply_manifest(manifest, catch_changes: true)

    expect(on(default, https_get('kv/https-test/value?raw')).stdout).to eq('initial value')
    policies = JSON.parse(on(default, https_get('acl/policies')).stdout)
    expect(policies.map { |policy| policy['Name'] }).to include('https-test-policy')
    token = JSON.parse(on(default, https_get('acl/token/89a3e8d4-a137-4f6b-aabb-000000000001')).stdout)
    expect(token['Policies'].map { |policy| policy['Name'] }).to eq(['https-test-policy'])

    expect(on(default, 'curl --silent --max-time 5 http://127.0.0.1:8500/v1/status/leader', acceptable_exit_codes: [0, 7]).exit_code).to eq(7)
    expect(on(default, https_get('status/leader', ca_file: 'wrong-ca.pem'), acceptable_exit_codes: [0, 60]).exit_code).to eq(60)
    expect(on(default, https_get('status/leader', hostname: '127.0.0.1'), acceptable_exit_codes: [0, 60]).exit_code).to eq(60)
    # TLS versions and curl backends report a rejected client handshake with different exit codes.
    expect(on(default, https_get('status/leader', client: false), acceptable_exit_codes: [0, 35, 55, 56]).exit_code).not_to eq(0)

    pid = on(default, 'systemctl show consul --property=MainPID').stdout
    expect(pid).to match(%r{MainPID=[1-9]\d*})
    updated = https_manifest(certificates, service_port: 8081, value: 'updated value')
    result = apply_manifest(updated, catch_failures: true)
    expect(result.stdout).to match(%r{reload consul service.*Triggered})
    expect(on(default, 'systemctl show consul --property=MainPID').stdout).to eq(pid)
    services = JSON.parse(on(default, https_get('agent/services')).stdout)
    expect(services.fetch('https-test-service').fetch('Port')).to eq(8081)
    expect(on(default, https_get('kv/https-test/value?raw')).stdout).to eq('updated value')
    apply_manifest(updated, catch_changes: true)
  ensure
    apply_manifest(<<~PUPPET, catch_failures: true)
      service { 'consul': ensure => stopped }
      -> file { ['/etc/consul-https-test', '/etc/consul-https-pki', '/opt/consul-https-test']:
        ensure => absent,
        force  => true,
      }
    PUPPET
  end
end
