def validate_checks(obj)
  case obj
    when Array
      obj.each do |c|
        validate_checks(c)
      end
    when Hash
        if ( (obj.key?("http") || obj.key?("args") || obj.key?("tcp")) && (! obj.key?("interval")) )
          raise Puppet::ParseError.new('interval must be defined for tcp, http, and args checks')
        end

        if obj.key?("ttl")
          if (obj.key?("http") || obj.key?("args") || obj.key?("tcp") || obj.key?("interval"))
            raise Puppet::ParseError.new('args, http, tcp, and interval must not be defined for ttl checks')
          end
        elsif obj.key?("http")
          if (obj.key?("args") || obj.key?("tcp"))
            raise Puppet::ParseError.new('args and tcp must not be defined for http checks')
          end
        elsif obj.key?("tcp")
          if (obj.key?("http") || obj.key?("args"))
            raise Puppet::ParseError.new('args and http must not be defined for tcp checks')
          end
        elsif obj.key?("args")
          if (obj.key?("http") || obj.key?("tcp"))
            raise Puppet::ParseError.new('http and tcp must not be defined for args checks')
          end
        else
          raise Puppet::ParseError.new('One of ttl, args, tcp, or http must be defined.')
        end
    else
      raise Puppet::ParseError.new("Unable to handle object of type <%s>" % obj.class.to_s)
  end
end

module Puppet::Parser::Functions
  newfunction(:consul_validate_checks, :doc => <<-EOS
This function validates the contents of an array of checks

*Examples:*

    consul_validate_checks({'key'=>'value'})
    consul_validate_checks([
      {'key'=>'value'},
      {'key'=>'value'}
    ])

Would return: true if valid, and raise exception otherwise
    EOS
  ) do |arguments|
    raise(Puppet::ParseError, "validate_checks(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size != 1
    return validate_checks(arguments[0])
  end
end
