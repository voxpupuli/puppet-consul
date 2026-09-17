require 'puppet_x'
require 'net/http'
require 'openssl'

module PuppetX::Consul
  module HTTPClient
    TLS_PARAMETERS = %i[ca_file ca_path client_cert client_key].freeze

    def self.tls_options(resource)
      TLS_PARAMETERS.to_h { |parameter| [parameter, resource[parameter]] }
    end

    def self.build(uri, options = {})
      http = Net::HTTP.new(uri.host, uri.port)
      return http unless uri.is_a?(URI::HTTPS)

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.verify_hostname = true
      http.ca_file = options[:ca_file] if options[:ca_file]
      http.ca_path = options[:ca_path] if options[:ca_path]

      if options[:client_cert] || options[:client_key]
        raise Puppet::Error, 'Consul client_cert and client_key must be supplied together' unless options[:client_cert] && options[:client_key]

        # PEM bundles contain the leaf certificate followed by its intermediate CAs.
        certificates = File.read(options[:client_cert]).scan(%r{-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----}m)
        raise Puppet::Error, 'Consul client_cert does not contain a PEM certificate' if certificates.empty?

        http.cert = OpenSSL::X509::Certificate.new(certificates.shift)
        http.extra_chain_cert = certificates.map { |pem| OpenSSL::X509::Certificate.new(pem) }
        http.key = OpenSSL::PKey.read(File.read(options[:client_key]), '')
        raise Puppet::Error, 'Consul client_key does not match client_cert' unless http.cert.check_private_key(http.key)
      end

      http
    end
  end
end
