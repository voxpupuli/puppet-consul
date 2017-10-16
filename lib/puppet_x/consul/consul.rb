require 'pathname'
require 'json'
require 'base64'
require Pathname.new(__FILE__).dirname.expand_path

module PuppetX
  module Consul
    class ConsulValueError < StandardError
    end

    class Consul
      @@option_defaults = {
        tries: 3,
        retry_period: 1,
        read_timeout: 3,
        connect_timeout: 3,
        use_ssl: false,
        ssl_verify: false,
        use_auth: false,
        document: 'RAW'
      }
      # confined_to_keys checks if the configuration allows the lookup of this key.
      # @param [String] hostname (localhost) the hostname for the consul api
      # @param [String] token the api token to be used for authentication against consul
      # @param [Integer] port (8500) the port to use for the consul api
      # @param [Hash] opts the options for a consul api connection
      # @option opts [String] :document (yaml) parse the found data according to the specified format. yaml, json or raw
      # @option opts [Integer] :tries (3) retry a failed connection X times
      # @option opts [Integer] :retry_period (1) how long to sleep between retries
      # @option opts [Integer] :read_timeout (3) for http library
      # @option opts [Integer] :connect_timeout (3) for http library
      # @option opts [Bool] :use_ssl (false) use an ssl connection
      # @option opts [Bool] :ssl_verify (false) verify the certificate of the ssl connection
      # @option opts [String] :ssl_ca_cert Specify location of the CA certificate
      # @option opts [String] :ssl_cert Specify location of the ssl certificate
      # @option opts [String] :ssl_key Specify location of the ssl key
      # @option opts [Bool] :use_auth When set to true, enable basic auth
      # @option opts [String] :auth_user The user for basic auth
      # @option opts [Bool] :auth_pass The password for basic auth
      #
      # @return [Boolean] true if lookup can proceed
      # @raise ArgumentError if configuration data is wrong.
      #
      def initialize(hostname = 'localhost',
                     token = '',
                     port = 8500,
                     opts = {})

        require 'net/http'
        require 'net/https'
        @config = @@option_defaults.merge(opts)
        @config[:token] = token

        # @debug_log = @config[:debug_log]
        @http = Net::HTTP.new(hostname, port)
        @http.read_timeout = @config[:read_timeout]
        @http.open_timeout = @config[:connect_timeout]

        if @config[:use_ssl]
          @http.use_ssl = true

          @http.verify_mode = if @config[:ssl_verify]
                                OpenSSL::SSL::VERIFY_PEER
                              else
                                OpenSSL::SSL::VERIFY_NONE
                              end

          if @config[:ssl_cert]
            store = OpenSSL::X509::Store.new
            store.add_cert(OpenSSL::X509::Certificate.new(File.read(@config[:ssl_ca_cert])))
            @http.cert_store = store

            @http.key = OpenSSL::PKey::RSA.new(File.read(@config[:ssl_cert]))
            @http.cert = OpenSSL::X509::Certificate.new(File.read(@config[:ssl_key]))
          end
        else
          @http.use_ssl = false
        end
      end

      def put(path, body, opts={})
        path = with_query_parameters(path, opts)
        req = Net::HTTP::Put.new(path)

        with_consul_token(req)
        with_auth(req)

        if body.is_a? String
          req.body = body 
        elsif body
          req.body = body.to_json 
        end
        res = request(req)
    
        raise(Puppet::Error, "Session put: invalid return code #{res.code} uri: #{path} body: #{req.body}") if res.code != '200'
      end

      def delete(path, body, opts={})
        path = with_query_parameters(path, opts)
        req = Net::HTTP::Delete.new(path)

        with_consul_token(req)
        with_auth(req)

        if body.is_a? String
          req.body = body 
        elsif body
          req.body = body.to_json 
        end
        res = request(req)

        raise(Puppet::Error, "Session delete: invalid return code #{res.code} uri: #{path} body: #{req.body}") if res.code != '200'
      end

      def post(path, body, opts={})
        path = with_query_parameters(path, opts)
        req = Net::HTTP::Post.new(path)

        with_consul_token(req)
        with_auth(req)

        if body.is_a? String
          req.body = body 
        elsif  body
          req.body = body.to_json 
        end
        res = request(req)

        raise(Puppet::Error, "Session post: invalid return code #{res.code} uri: #{path} body: #{req.body}") if res.code != '200'
      end


      # @param [Hash] opts the options for a consul api connection
      # @option opts [String] :dc ('') Specifies the datacenter for the request
      # @option opts [Integer] :recurse (false) Specifies if the lookup should
      #    be recursive and key treated as a prefix instead of a literal match.
      def get(path, opts = {})
        path = with_query_parameters(path, opts)
        httpreq = Net::HTTP::Get.new(path)

        with_consul_token(httpreq)
        with_auth(httpreq)

        httpres = retry_request(httpreq)

        unless httpres
          Puppet.debug('HTTP request failed.')
          # puts 'HTTP request failed.'
          return nil
        end

        httpres
      end

      def get_safe(path, opts = {})
        res = get(path, opts)
        return [] unless res

        if res.is_a?(Net::HTTPNotFound)
          # no keys found
          Puppet.debug("No keys found on #{path}")
          return []
        elsif !res.is_a?(Net::HTTPSuccess)
          Puppet.warning("Cannot retrieve data: invalid return code #{res.code} uri: #{path}")
          return []
        end

        JSON.parse(res.body)
      end

      # @param [Hash] opts the options for a consul api connection
      # @option opts [String] :dc ('') Specifies the datacenter for the request
      # @option opts [Integer] :recurse (false) Specifies if the lookup should be recursive and key treated as a prefix instead of a literal match.
      def get_kv(path, opts = {})
        path = '' if path == '/'
        res = get("/v1/kv/#{path}", opts)
        return nil unless res

        if res.is_a?(Net::HTTPNotFound)
          # no keys found
          Puppet.debug("No keys found on #{path}")
          return []
        elsif !res.is_a?(Net::HTTPSuccess)
          Puppet.debug("HTTP response code was #{res.code}")
          # puts "http response code: #{httpres.code}"
          return nil
        end

        data = JSON.parse(res.body)
        begin
          decode_kv_values(data)
        rescue JSON::ParserError
          raise ConsulValueError, "could not parse json value at: #{path}"
        rescue Psych::SyntaxError
          raise ConsulValueError, "could not parse yaml value at: #{path}"
        end
      end

      private

      # decode_kv_values decodes the base64 and yaml or json if specified.
      def decode_kv_values(kv_data)
        kv_data.map! do |x|
          next x if x['Value'].nil?

          decoded = Base64.decode64(x['Value'])

          decoded = YAML.safe_load(decoded) if @config[:document].casecmp('yaml').zero?

          decoded = JSON.parse(decoded) if @config[:document].casecmp('json').zero?

          x['Value'] = decoded
          x
        end
        kv_data
      end

      def with_auth(req)
        req.basic_auth @config[:auth_user], @config[:auth_pass] if @config[:use_auth]
      end

      def with_consul_token(req)
        req.add_field('X-Consul-Token', @config[:token]) if @config[:token]
      end

      def with_query_parameters(path, params = {})
        real_params = {}
        params.each do |key, value|
          real_params[key.to_s] = nil if key.to_sym == :recurse && value
          real_params[key.to_s] = value if key.to_sym == :dc
          real_params[key.to_s] = value if key.to_sym == :flags
        end

        encoded_params = URI.encode_www_form(real_params)
        [path, encoded_params].join('?')
      end

      # retry_request executes the http request with the following:
      # 1. Retries the request for certain raised errors.
      # 2. Retries the request if the http status code is unexpected (not 200 or 404)
      def retry_request(req)
        httpres = nil
        (1..@config[:tries]).each do |i|
          unless i == 1
            Puppet.debug("retrying Consul API query in #{i} seconds")
            sleep @config[:retry_period]
          end

          begin
            httpres = @http.request(req)
          rescue Errno::EINVAL, Errno::ECONNRESET, EOFError,
                 Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => exc
            Puppet.debug("Error while query'ing consul: #{exc}")
          end
          break if httpres.is_a?(Net::HTTPSuccess)
          break if httpres.is_a?(Net::HTTPNotFound)
        end
        httpres
      end

      def request(req)
        begin
          httpres = @http.request(req)
          return httpres
        rescue Errno::EINVAL, Errno::ECONNRESET, EOFError,
               Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => exc
          raise Puppet::Error, "Session failed request. #{req.path} exception: ${exc}"
        end
      end
    end
  end
end
