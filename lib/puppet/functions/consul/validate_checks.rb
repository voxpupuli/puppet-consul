Puppet::Functions.create_function(:'consul::validate_checks') do
  local_types do
    type 'HashOrArray = Variant[Hash,Array]'
  end

  dispatch :validate_checks do
    param 'HashOrArray', :obj
  end

  def validate_checks(obj)
    case obj
    when Array
      obj.each do |c|
        validate_checks(c)
      end
    when Hash
      raise Puppet::ParseError, 'interval must be defined for tcp, http, grpc and script checks' if (obj.key?('http') || (obj.key?('script') || obj.key?('args')) || obj.key?('tcp') || obj.key?('grpc')) && !obj.key?('interval')

      if obj.key?('ttl')
        raise Puppet::ParseError, 'script, http, tcp, grpc and interval must not be defined for ttl checks' if (obj.key?('http') || (obj.key?('args') || obj.key?('script')) || obj.key?('tcp') || obj.key?('grpc')) || obj.key?('interval')
      elsif obj.key?('http')
        raise Puppet::ParseError, 'script, tcp and grpc must not be defined for http checks' if (obj.key?('args') || obj.key?('script')) || obj.key?('tcp') || obj.key?('grpc')
      elsif obj.key?('grpc')
        raise Puppet::ParseError, 'script, tcp and http must not be defined for grpc checks' if (obj.key?('args') || obj.key?('script')) || obj.key?('tcp') || obj.key?('http')
      elsif obj.key?('tcp')
        raise Puppet::ParseError, 'script, http and grpc must not be defined for tcp checks' if obj.key?('http') || (obj.key?('args') || obj.key?('script')) || obj.key?('grpc')
      elsif obj.key?('args') || obj.key?('script')
        raise Puppet::ParseError, 'http, grpc and tcp must not be defined for script checks' if obj.key?('http') || obj.key?('tcp') || obj.key?('grpc')
      elsif obj.key?('alias_service')
        raise Puppet::ParseError, 'alias_service must not define http, tcp, grpc, args, script, or interval' if obj.key?('http') || obj.key?('tcp') || obj.key?('args') || obj.key?('script') || obj.key?('interval') || obj.key?('grpc')
      else
        raise Puppet::ParseError, 'One of ttl, script, tcp, grpc or http must be defined.'
      end
    else
      raise Puppet::ParseError, 'Unable to handle object of type <%s>' % obj.class.to_s
    end
  end
end
