require 'spec_helper'
require_relative '../../../../lib/puppet_x/consul/http_client'
require_relative '../../../support/consul_tls'

{
  consul_acl: ['/v1/acl/list', '/v1/acl/create', :put],
  consul_key_value: ['/v1/kv/?dc=&recurse', '/v1/kv/test?dc=&flags=0', :put],
  consul_policy: ['/v1/acl/policies', '/v1/acl/policy', :put],
  consul_prepared_query: ['/v1/query', '/v1/query', :post],
  consul_token: ['/v1/acl/tokens', '/v1/acl/token', :put],
}.each do |type_name, (list_path, create_path, verb)|
  describe "#{type_name} HTTPS provider" do
    include ConsulTLS

    let(:provider) { Puppet::Type.type(type_name).provider(:default) }
    let(:created) { { 'ID' => 'created-id', 'AccessorID' => 'created-accessor', 'SecretID' => 'created-secret', 'Policies' => [] }.to_json }
    let(:directory) { Dir.mktmpdir('consul-provider-tls') }
    let(:tls_options) do
      ca = issue_certificate('CA', authority: true)
      client = issue_certificate('Puppet', issuer: ca, usage: 'clientAuth')
      write_identity(directory, 'client', client).merge(ca_file: File.join(directory, 'ca.pem'), ca_path: directory)
    end
    let(:resource) { Puppet::Type.type(type_name).new({ name: 'test', ensure: :present, protocol: 'https', port: 8501, acl_api_token: 'test-token', api_tries: 1 }.merge(tls_options)) }

    def base_url
      'https://localhost:8501'
    end

    after do
      provider.reset
      FileUtils.remove_entry(directory)
    end

    it 'passes the CA and client credentials to both reads and writes' do
      stub_request(:get, base_url + list_path).to_return(body: '[]')
      write = stub_request(verb, base_url + create_path).with(headers: { 'X-Consul-Token' => 'test-token' }).to_return(body: created)
      allow(PuppetX::Consul::HTTPClient).to receive(:build).and_call_original
      provider.prefetch('test' => resource)
      resource.provider.create
      resource.provider.flush
      expect(PuppetX::Consul::HTTPClient).to have_received(:build).with(anything, tls_options).at_least(:once)
      expect(write).to have_been_requested
    end

    it 'uses the configured TLS credentials when deleting an existing resource' do
      existing = { 'Name' => 'test', 'ID' => 'existing-id', 'Type' => 'client', 'Rules' => '', 'Key' => 'test', 'Value' => '', 'Flags' => 0,
                   'AccessorID' => 'existing-id', 'Description' => 'test', 'Datacenters' => [], 'Policies' => [], }
      resource[:accessor_id] = 'existing-id' if type_name == :consul_token
      resource[:ensure] = :absent
      stub_request(:get, base_url + list_path).to_return(body: [existing].to_json)
      stub_request(:get, "#{base_url}/v1/acl/policy/existing-id").to_return(body: { 'Rules' => '' }.to_json) if type_name == :consul_policy
      delete_path, delete_verb = {
        consul_acl: ['/v1/acl/destroy/existing-id', :put],
        consul_key_value: ['/v1/kv/test?dc=', :delete],
        consul_policy: ['/v1/acl/policy/existing-id', :delete],
        consul_prepared_query: ['/v1/query/existing-id', :delete],
        consul_token: ['/v1/acl/token/existing-id', :delete],
      }.fetch(type_name)
      deletion = stub_request(delete_verb, base_url + delete_path).with(headers: { 'X-Consul-Token' => 'test-token' }).to_return(body: 'true')
      allow(PuppetX::Consul::HTTPClient).to receive(:build).and_call_original
      provider.prefetch('test' => resource)
      resource.provider.destroy
      resource.provider.flush
      expect(PuppetX::Consul::HTTPClient).to have_received(:build).with(anything, tls_options).at_least(:once)
      expect(deletion).to have_been_requested
    end

    it 'separates cached reads by ACL token on the same endpoint' do
      other = Puppet::Type.type(type_name).new({ name: 'other', protocol: 'https', port: 8501, acl_api_token: 'other-token', api_tries: 1 }.merge(tls_options))
      first_read = stub_request(:get, base_url + list_path).with(headers: { 'X-Consul-Token' => 'test-token' }).to_return(body: '[]')
      second_read = stub_request(:get, base_url + list_path).with(headers: { 'X-Consul-Token' => 'other-token' }).to_return(body: '[]')
      provider.prefetch('test' => resource, 'other' => other)
      expect(first_read).to have_been_requested.once
      expect(second_read).to have_been_requested.once
    end

    it 'propagates certificate verification failures during prefetch' do
      stub_request(:get, base_url + list_path).to_raise(OpenSSL::SSL::SSLError.new('certificate verify failed'))
      expect { provider.prefetch('test' => resource) }.to raise_error(OpenSSL::SSL::SSLError, %r{certificate verify failed})
    end

    it 'propagates certificate verification failures during writes' do
      stub_request(:get, base_url + list_path).to_return(body: '[]')
      stub_request(verb, base_url + create_path).to_raise(OpenSSL::SSL::SSLError.new('certificate verify failed'))
      provider.prefetch('test' => resource)
      resource.provider.create
      expect { resource.provider.flush }.to raise_error(OpenSSL::SSL::SSLError, %r{certificate verify failed})
    end

    it 'does not reuse cached reads across Puppet runs' do
      read = stub_request(:get, base_url + list_path).to_return(body: '[]')
      2.times { provider.prefetch('test' => resource) }
      expect(read).to have_been_requested.twice
    end

    it 'separates cached reads by CA even for the same endpoint and token' do
      other = Puppet::Type.type(type_name).new({ name: 'other', protocol: 'https', port: 8501, acl_api_token: 'test-token', api_tries: 1 }.merge(tls_options).merge(ca_file: '/other-ca.pem'))
      read = stub_request(:get, base_url + list_path).to_return(body: '[]')
      provider.prefetch({ 'test' => resource, 'other' => other })
      expect(read).to have_been_requested.twice
    end

    it 'separates cached reads by client identity even for the same endpoint and CA' do
      other_identity = issue_certificate('Other Puppet')
      other_options = tls_options.merge(write_identity(directory, 'other', other_identity))
      other = Puppet::Type.type(type_name).new({ name: 'other', protocol: 'https', port: 8501, acl_api_token: 'test-token', api_tries: 1 }.merge(other_options))
      read = stub_request(:get, base_url + list_path).to_return(body: '[]')
      provider.prefetch({ 'test' => resource, 'other' => other })
      expect(read).to have_been_requested.twice
    end
  end
end

%i[consul_policy consul_token].each do |type_name|
  describe "#{type_name} connection isolation" do
    let(:provider) { Puppet::Type.type(type_name).provider(:default) }
    let(:kind) { (type_name == :consul_policy) ? 'policy' : 'token' }
    let(:list_path) { (kind == 'policy') ? 'policies' : 'tokens' }

    after { provider.reset }

    it 'keeps the correct write client when revisiting a cached endpoint' do
      resources = {}
      %w[first second third].each_with_index do |name, index|
        host = (index == 1) ? 'second.test' : 'first.test'
        resources[name] = Puppet::Type.type(type_name).new(name: name, ensure: :present, hostname: host, protocol: 'https', port: 8501, acl_api_token: host)
      end
      ['first.test', 'second.test'].each do |host|
        stub_request(:get, "https://#{host}:8501/v1/acl/#{list_path}").with(headers: { 'X-Consul-Token' => host }).to_return(body: '[]')
        stub_request(:put, "https://#{host}:8501/v1/acl/#{kind}").with(headers: { 'X-Consul-Token' => host }).to_return(body: { ID: 'id', AccessorID: 'accessor', SecretID: 'secret' }.to_json)
      end
      provider.prefetch(resources)
      resources.each_value do |resource|
        resource.provider.create
        resource.provider.flush
      end
      expect(a_request(:put, "https://first.test:8501/v1/acl/#{kind}")).to have_been_made.twice
      expect(a_request(:put, "https://second.test:8501/v1/acl/#{kind}")).to have_been_made.once
    end
  end
end
