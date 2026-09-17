require 'spec_helper'
require_relative '../../../support/consul_tls'
require_relative '../../../../lib/puppet_x/consul/http_client'

describe PuppetX::Consul::HTTPClient do
  include ConsulTLS

  let(:ca) { issue_certificate("Test CA #{File.basename(directory)}", authority: true) }
  let(:endpoint) do
    start_tls_server(server_identity, authority: ca, mutual: mutual) do |_request, _body, peer|
      [200, peer ? peer.subject.to_s : 'verified']
    end
  end
  let(:server_identity) { issue_certificate('localhost', issuer: ca, san: 'DNS:localhost', usage: 'serverAuth') }
  let(:mutual) { false }
  let(:directory) { Dir.mktmpdir('consul-tls') }

  def ca_file
    path = File.join(directory, 'ca.pem')
    File.write(path, ca[:cert].to_pem)
    path
  end

  around do |example|
    WebMock.disable!
    connection = endpoint
    Timeout.timeout(15) { example.run }
  ensure
    connection&.[](1)&.kill
    connection&.[](1)&.join
    connection&.[](2)&.close
    FileUtils.remove_entry(directory)
    WebMock.enable!
  end

  def client_identity
    issue_certificate('Puppet', issuer: ca, usage: 'clientAuth')
  end

  def request(options = {}, uri = endpoint[0])
    described_class.build(uri, options).get('/').body
  end

  it 'verifies a server signed by the configured private CA' do
    expect(request(ca_file: ca_file)).to eq('verified')
  end

  it 'rejects an untrusted CA' do
    wrong_ca = issue_certificate('Wrong CA', authority: true)
    wrong_ca_file = File.join(directory, 'wrong-ca.pem')
    File.write(wrong_ca_file, wrong_ca[:cert].to_pem)
    expect { request(ca_file: wrong_ca_file) }.to raise_error(OpenSSL::SSL::SSLError, %r{certificate verify failed})
  end

  it 'rejects a hostname that is missing from the certificate SAN' do
    uri = URI("https://127.0.0.1:#{endpoint[0].port}")
    expect { request({ ca_file: ca_file }, uri) }.to raise_error(OpenSSL::SSL::SSLError, %r{certificate verify failed|does not match})
  end

  it 'uses an OpenSSL hashed CA directory' do
    File.write(File.join(directory, "#{format('%08x', ca[:cert].subject.hash)}.0"), ca[:cert].to_pem)
    expect(request(ca_path: directory)).to eq('verified')
  end

  it 'rejects a missing client certificate file' do
    expect do
      request(ca_file: ca_file, client_cert: File.join(directory, 'missing.pem'), client_key: '/missing-key.pem')
    end.to raise_error(Errno::ENOENT)
  end

  it 'rejects a mismatched private key' do
    options = write_identity(directory, 'client', client_identity)
    File.write(options[:client_key], ca[:key].to_pem)
    expect { request(options.merge(ca_file: ca_file)) }.to raise_error(Puppet::Error, %r{does not match})
  end

  context 'when the API requires mutual TLS' do
    let(:mutual) { true }

    it 'sends the client certificate and proves possession of its key' do
      options = write_identity(directory, 'client', client_identity)
      expect(request(options.merge(ca_file: ca_file))).to eq('/CN=Puppet')
    end

    it 'sends intermediate certificates from the client PEM bundle' do
      intermediate = issue_certificate('Intermediate CA', issuer: ca, authority: true)
      client = issue_certificate('Puppet via intermediate', issuer: intermediate, usage: 'clientAuth')
      options = write_identity(directory, 'client', client, chain: [intermediate[:cert]])
      expect(request(options.merge(ca_file: ca_file))).to eq('/CN=Puppet via intermediate')
    end

    it 'rejects a connection without a client certificate' do
      expect { request(ca_file: ca_file) }.to raise_error(OpenSSL::SSL::SSLError)
    end

    it 'rejects a client certificate signed by another CA' do
      other_ca = issue_certificate('Other CA', authority: true)
      client = issue_certificate('Unknown client', issuer: other_ca, usage: 'clientAuth')
      options = write_identity(directory, 'client', client)
      expect { request(options.merge(ca_file: ca_file)) }.to raise_error(OpenSSL::SSL::SSLError)
    end
  end
end
