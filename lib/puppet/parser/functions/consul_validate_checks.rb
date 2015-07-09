def validate_checks(obj)
  case obj
    when Array
      obj.each do |c|
        validate_checks(c)
      end
    when Hash
        if (obj.key?("http") && obj.key?("script"))
          raise Puppet::ParseError.new('script and http must not be defined together')
        end

        if obj.key?("ttl")
          if (obj.key?("http") || obj.key?("script") || obj.key?("interval"))
            raise Puppet::ParseError.new('script or http must not be defined for ttl checks')
          end
        elsif obj.key?("http")
          if (! obj.key?("interval"))
            raise Puppet::ParseError.new('http must be defined for interval checks')
          end
        elsif obj.key?("script")
          if (! obj.key?("interval"))
            raise Puppet::ParseError.new('script must be defined for interval checks')
          end
        else
          raise Puppet::ParseError.new('One of ttl, script, or http must be defined.')
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
