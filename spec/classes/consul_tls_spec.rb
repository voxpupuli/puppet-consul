require 'spec_helper'

describe 'consul' do
  let(:facts) { on_supported_os['debian-12-x86_64'] }
  let(:params) do
    {
      config_hash: {
        'ports' => { 'http' => -1, 'https' => 8501 },
        'tls' => {
          'defaults' => { 'ca_file' => '/tls/ca.pem', 'cert_file' => '/tls/agent.pem', 'key_file' => '/tls/agent-key.pem', 'verify_incoming' => true },
        },
      },
      acl_api_protocol: 'https',
      acl_api_hostname: 'consul.example.test',
      acl_api_port: 8501,
      join_wan: 'wan.example.test',
    }
  end
  let(:tls_options) { '-http-addr=https://consul.example.test:8501 -ca-file=/tls/ca.pem -client-cert=/tls/agent.pem -client-key=/tls/agent-key.pem' }

  it { is_expected.to compile.with_all_deps }

  it 'uses verified HTTPS for reload, WAN join and its guard' do
    is_expected.to contain_exec('reload consul service').with(command: "consul reload #{tls_options}", environment: ['CONSUL_HTTP_SSL_VERIFY=true'])
    is_expected.to contain_exec('join consul wan').with(command: "consul join -wan #{tls_options} wan.example.test", environment: ['CONSUL_HTTP_SSL_VERIFY=true'])
    expect(catalogue.resource('Exec', 'join consul wan')[:unless]).to include("consul members -wan -detailed #{tls_options} |")
  end

  it 'renders the agent TLS settings unchanged' do
    content = catalogue.resource('File', 'consul config')[:content]
    expect(JSON.parse(content)['tls']).to eq(params[:config_hash]['tls'])
    expect(JSON.parse(content)['ports']).to eq('http' => -1, 'https' => 8501)
  end

  context 'with explicit API credentials and resource overrides' do
    let(:params) do
      super().merge(
        acl_api_ca_file: '/api/ca.pem',
        acl_api_ca_path: '/api/cas',
        acl_api_client_cert: '/api/puppet.pem',
        acl_api_client_key: '/api/puppet-key.pem',
        policies: { 'test' => { 'ca_file' => '/other/ca.pem' } },
        tokens: { 'test' => { 'accessor_id' => 'test-id' } },
      )
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_consul_policy('test').with(ca_file: '/other/ca.pem', ca_path: '/api/cas', client_cert: '/api/puppet.pem', client_key: '/api/puppet-key.pem') }
    it { is_expected.to contain_consul_token('test').with(ca_file: '/api/ca.pem', ca_path: '/api/cas', client_cert: '/api/puppet.pem', client_key: '/api/puppet-key.pem') }
    it { is_expected.to contain_exec('reload consul service').with_command('consul reload -http-addr=https://consul.example.test:8501 -ca-file=/api/ca.pem -ca-path=/api/cas -client-cert=/api/puppet.pem -client-key=/api/puppet-key.pem') }
  end

  context 'with an HTTPS override disabling client verification' do
    let(:params) do
      base = super()
      base[:config_hash]['tls']['https'] = { 'verify_incoming' => false, 'ca_file' => '/https/ca.pem' }
      base
    end

    it { is_expected.to contain_exec('reload consul service').with_command('consul reload -http-addr=https://consul.example.test:8501 -ca-file=/https/ca.pem') }
  end

  context 'with legacy TLS settings and HTTP disabled' do
    let(:params) do
      super().merge(
        acl_api_protocol: 'http',
        config_hash: { 'ports' => { 'http' => -1, 'https' => 8501 }, 'ca_file' => '/tls/ca.pem', 'cert_file' => '/tls/agent.pem', 'key_file' => '/tls/agent-key.pem', 'verify_incoming' => true },
      )
    end

    it { is_expected.to contain_exec('reload consul service').with_command("consul reload #{tls_options}") }
  end

  context 'with a custom reload command' do
    let(:params) { super().merge(reload_command: 'consul reload -http-addr=https://custom.test:8501 -ca-file=/custom/ca.pem') }

    it { is_expected.to contain_exec('reload consul service').with_command(sensitive('consul reload -http-addr=https://custom.test:8501 -ca-file=/custom/ca.pem')) }
    it { is_expected.to contain_exec('reload consul service').with_environment(['CONSUL_HTTP_SSL_VERIFY=true']) }
  end

  context 'with only one client credential' do
    let(:params) { super().merge(acl_api_client_cert: '/client.pem') }

    it { is_expected.to compile.and_raise_error(%r{must be supplied together}) }
  end

  context 'with spaces in certificate paths' do
    let(:params) { super().merge(acl_api_ca_file: '/api certificates/ca.pem') }

    it { is_expected.to contain_exec('reload consul service').with_command('consul reload -http-addr=https://consul.example.test:8501 "-ca-file=/api certificates/ca.pem" -client-cert=/tls/agent.pem -client-key=/tls/agent-key.pem') }
  end

  context 'with an ACL token' do
    let(:params) { super().merge(acl_api_token: 'test-token') }

    it { is_expected.to contain_exec('reload consul service').with_command(sensitive("consul reload #{tls_options} -token=test-token")) }
    it { is_expected.to contain_exec('join consul wan').with_command(sensitive("consul join -wan #{tls_options} -token=test-token wan.example.test")) }
  end
end
