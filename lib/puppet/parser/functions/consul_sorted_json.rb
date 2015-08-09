require 'json'

module ConsulSortedJson

  module_function


  def sorted_json(config_hash, pretty)
    cleaned = convert_integers(config_hash)

    if pretty
      JSON.pretty_generate( sort_keys( cleaned ) )
    else
      sort_keys( cleaned ).to_json
    end
  end

  # Recursively convert all quoted integers(strings) to a real
  # integer. We can assume, given the consul configuration schema,
  # that all integers in strings are meant to be real integers.
  def convert_integers(obj)
    case obj
    when Fixnum, Float, TrueClass, FalseClass, NilClass
      return obj
    when String
      if obj.match(/\A[-]?[0-9]+\z/) # integer check
        obj.to_i
      else
        obj
      end
    when Array
      obj.map{ |element| convert_integers(element) } # go deeper
    when Hash
      obj.merge( obj ) {|k, v| convert_integers( v ) } # go deeper
    else
      raise Exception("Unable to handle object of type <%s>" % obj.class.to_s)
    end
  end

  # recursively sort keys
  def sort_keys(h)
    keys = h.keys.sort
    Hash[keys.zip(h.values_at(*keys).map{ |e| e.is_a?(Hash) ? sort_keys(e) : e  })]
  end
end

module Puppet::Parser::Functions

  doc = <<-DOC
This function takes configuration data and returns a json string that
can be rendered to a file. It sorts the keys recursively. This is
needed to ensure that a change in the order of data received does not
register a change in the file and restart services etc.. It also
converts integers in strings to real integers.

*Examples:*

    sorted_json({'b' => 2, 'a'=>1})
    =>  {'a' => 1, 'b' => 2}

    sorted_json({'b' => 2, 'a'=>1}, true)
    =>  {
          'a' => 1,
          'b' => 2
        }

DOC

  # custom functions must be called with a single array
  newfunction(:consul_sorted_json, :type => :rvalue, :doc => doc  ) do |config|
    pretty = config[1] || false # backwards compatible
    raise(Puppet::ParseError, "sorted_json(): takes a hash") unless config[0].is_a?(Hash) # validate
    _config = config[0].delete_if {|key, value| value == :undef }  #cleanup
    return ConsulSortedJson.sorted_json(_config, pretty)
  end
end
