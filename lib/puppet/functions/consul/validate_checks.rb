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
      raise Puppet::ParseError, 'interval must be defined for tcp, http, and script checks' if (obj.key?('http') || (obj.key?('script') || obj.key?('args')) || obj.key?('tcp')) && !obj.key?('interval')

      if obj.key?('ttl')
        raise Puppet::ParseError, 'script, http, tcp, and interval must not be defined for ttl checks' if obj.key?('http') || (obj.key?('args') || obj.key?('script')) || obj.key?('tcp') || obj.key?('interval')
      elsif obj.key?('http')
        raise Puppet::ParseError, 'script and tcp must not be defined for http checks' if (obj.key?('args') || obj.key?('script')) || obj.key?('tcp')
      elsif obj.key?('tcp')
        raise Puppet::ParseError, 'script and http must not be defined for tcp checks' if obj.key?('http') || (obj.key?('args') || obj.key?('script'))
      elsif obj.key?('args') || obj.key?('script')
        raise Puppet::ParseError, 'http and tcp must not be defined for script checks' if obj.key?('http') || obj.key?('tcp')
      elsif obj.key?('alias_service')
        raise Puppet::ParseError, 'alias_service must not define http, tcp, args, script, or interval' if obj.key?('http') || obj.key?('tcp') || obj.key?('args') || obj.key?('script') || obj.key?('interval')
      else
        raise Puppet::ParseError, 'One of ttl, script, tcp, or http must be defined.'
      end
    else
      raise Puppet::ParseError, 'Unable to handle object of type <%s>' % obj.class.to_s
    end
  end
end
