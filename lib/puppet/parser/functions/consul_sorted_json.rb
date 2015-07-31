require 'json'


# Convert quoted integers (string) to int
def convert_integers(obj)
  case obj
    when Fixnum, Float, TrueClass, FalseClass, NilClass
      return obj
    when String
      if obj.match(/\A[-]?[0-9]+\z/)
        obj.to_i
      else
        obj
      end
    when Array
      obj.map{ |element| convert_integers(element) }
    when Hash
      sort_keys( obj.merge( obj ) {|k, v| convert_integers v } )
    else
      raise Exception("Unable to handle object of type <%s>" % obj.class.to_s)
  end
end

def sort_keys(h)
  keys = h.keys.sort
  Hash[keys.zip(h.values_at(*keys))]
end

def sorted_json(config_hash)
  cleaned = convert_integers(config_hash)
  JSON.pretty_generate( sort_keys( cleaned ) )
end

module Puppet::Parser::Functions
  newfunction(:consul_sorted_json, :type => :rvalue, :doc => <<-EOS
This function takes data, outputs making sure the hash keys are sorted

*Examples:*

    sorted_json({'key'=>'value'})

Would return: {'key':'value'}
    EOS
  ) do |arguments|
    raise(Puppet::ParseError, "sorted_json(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size != 1
    json = arguments[0].delete_if {|key, value| value == :undef }
    return sorted_json(json)
  end
end
