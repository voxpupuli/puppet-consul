require 'spec_helper'
require_relative '../../../support/consul_tls'

describe 'Consul HTTPS catalog application' do
  include ConsulTLS

  it 'creates TLS files before prefetch and is idempotent on the next Puppet run' do
    WebMock.disable!
    Dir.mktmpdir('consul-https-catalog') do |directory|
      ca = issue_certificate('Catalog CA', authority: true)
      server = issue_certificate('localhost', issuer: ca, san: 'DNS:localhost', usage: 'serverAuth')
      client = issue_certificate('Puppet', issuer: ca, usage: 'clientAuth')
      state = { value: nil, writes: 0 }
      endpoint, thread, listener = start_tls_server(server, authority: ca, mutual: true) do |request, body, _peer|
        if request.start_with?('GET ')
          state[:value] ? [200, [{ Key: 'test', Value: Base64.strict_encode64(state[:value]), Flags: 0 }].to_json] : [404, '']
        else
          state[:writes] += 1
          state[:value] = body
          [200, 'true']
        end
      end

      files = { 'ca.pem' => ca[:cert].to_pem, 'client.pem' => client[:cert].to_pem, 'client-key.pem' => client[:key].to_pem }
      Timeout.timeout(15) do
        2.times do |run|
          catalog = Puppet::Resource::Catalog.new
          catalog.host_config = false
          files.each do |filename, content|
            catalog.add_resource(Puppet::Type.type(:file).new(path: File.join(directory, filename), ensure: :file, content: content, backup: false))
          end
          catalog.add_resource(Puppet::Type.type(:consul_key_value).new(
                                 name: 'test', ensure: :present, value: 'managed via mTLS', protocol: 'https', hostname: endpoint.host, port: endpoint.port,
                                 ca_file: File.join(directory, 'ca.pem'), client_cert: File.join(directory, 'client.pem'), client_key: File.join(directory, 'client-key.pem')
                               ))
          transaction = catalog.apply
          expect(transaction.report.resource_statuses.values).not_to include(have_attributes(failed: true))
          expect(transaction.report.resource_statuses['Consul_key_value[test]'].changed).to eq(run.zero?)
          catalog.clear
        end
      end
      expect(state).to eq(value: 'managed via mTLS', writes: 1)
    ensure
      thread&.kill
      thread&.join
      listener&.close
    end
  ensure
    WebMock.enable!
  end
end
