require 'openssl'
require 'socket'
require 'tmpdir'
require 'timeout'

# Real certificates and a loopback HTTPS endpoint; no external Consul is required.
module ConsulTLS
  def issue_certificate(name, issuer: nil, authority: false, san: nil, usage: nil)
    key = OpenSSL::PKey::RSA.new(2048)
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = Random.rand(1..(2**64))
    cert.subject = OpenSSL::X509::Name.parse("/CN=#{name}")
    cert.issuer = issuer ? issuer[:cert].subject : cert.subject
    cert.public_key = key.public_key
    cert.not_before = Time.now - 60
    cert.not_after = Time.now + 3600
    factory = OpenSSL::X509::ExtensionFactory.new
    factory.subject_certificate = cert
    factory.issuer_certificate = issuer ? issuer[:cert] : cert
    cert.add_extension(factory.create_extension('basicConstraints', "CA:#{authority ? 'TRUE' : 'FALSE'}", true))
    cert.add_extension(factory.create_extension('keyUsage', authority ? 'keyCertSign,cRLSign' : 'digitalSignature,keyEncipherment', true))
    cert.add_extension(factory.create_extension('subjectAltName', san)) if san
    cert.add_extension(factory.create_extension('extendedKeyUsage', usage)) if usage
    cert.sign(issuer ? issuer[:key] : key, OpenSSL::Digest.new('SHA256'))
    { cert: cert, key: key }
  end

  def write_identity(directory, name, identity, chain: [])
    cert_path = File.join(directory, "#{name}.pem")
    key_path = File.join(directory, "#{name}-key.pem")
    File.write(cert_path, ([identity[:cert]] + chain).map(&:to_pem).join)
    File.write(key_path, identity[:key].to_pem)
    { client_cert: cert_path, client_key: key_path }
  end

  def start_tls_server(identity, authority:, mutual: false, &handler)
    listener = TCPServer.new('127.0.0.1', 0)
    context = OpenSSL::SSL::SSLContext.new
    context.cert = identity[:cert]
    context.key = identity[:key]
    context.cert_store = OpenSSL::X509::Store.new
    context.cert_store.add_cert(authority[:cert])
    context.verify_mode = mutual ? OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT : OpenSSL::SSL::VERIFY_NONE
    server = OpenSSL::SSL::SSLServer.new(listener, context)
    thread = Thread.new do
      loop do
        socket = nil
        begin
          socket = server.accept
          request = socket.gets
          headers = {}
          while (line = socket.gets) && line != "\r\n"
            key, value = line.split(':', 2)
            headers[key.downcase] = value.strip
          end
          body = socket.read(headers.fetch('content-length', '0').to_i)
          status, response = handler.call(request, body, socket.peer_cert)
          socket.write("HTTP/1.1 #{status} OK\r\nContent-Length: #{response.bytesize}\r\nConnection: close\r\n\r\n#{response}")
        rescue OpenSSL::SSL::SSLError, Errno::ECONNRESET, Errno::EPIPE
          # Rejected handshakes are expected in negative tests.
        ensure
          socket&.close
        end
      end
    end
    thread.report_on_exception = false
    yield_uri = URI("https://localhost:#{listener.addr[1]}")
    [yield_uri, thread, listener]
  end
end
