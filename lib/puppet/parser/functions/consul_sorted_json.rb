require 'json'

module JSON
  class << self
    @@loop = 0

    def sorted_generate(obj)
      case obj
        when NilClass, :undef, Fixnum, Float, TrueClass, FalseClass, String
          return simple_generate(obj)
        when Array
          arrayRet = []
          obj.each do |a|
            arrayRet.push(sorted_generate(a))
          end
          return "[" << arrayRet.join(',') << "]";
        when Hash
          ret = []
          obj.keys.sort.each do |k|
            ret.push(k.to_json << ":" << sorted_generate(obj[k]))
          end
          return "{" << ret.join(",") << "}";
        else
          raise Exception.new("Unable to handle object of type #{obj.class.name} with value #{obj.inspect}")
      end
    end

    def sorted_pretty_generate(obj, indent_len=4)

      # Indent length
      indent = " " * indent_len

      case obj
        when NilClass, :undef, Fixnum, Float, TrueClass, FalseClass, String
          return simple_generate(obj)
        when Array
          arrayRet = []

          # We need to increase the loop count before #each so the objects inside are indented twice.
          # When we come out of #each we decrease the loop count so the closing brace lines up properly.
          #
          # If you start with @@loop = 1, the count will be as follows
          #
          # "start_join": [     <-- @@loop == 1
          #   "192.168.50.20",  <-- @@loop == 2
          #   "192.168.50.21",  <-- @@loop == 2
          #   "192.168.50.22"   <-- @@loop == 2
          # ] <-- closing brace <-- @@loop == 1
          #
          @@loop += 1
          obj.each do |a|
            arrayRet.push(sorted_pretty_generate(a, indent_len))
          end
          @@loop -= 1

          return "[\n#{indent * (@@loop + 1)}" << arrayRet.join(",\n#{indent * (@@loop + 1)}") << "\n#{indent * @@loop}]";

        when Hash
          ret = []

          # This loop works in a similar way to the above
          @@loop += 1
          obj.keys.sort.each do |k|
            ret.push("#{indent * @@loop}" << k.to_json << ": " << sorted_pretty_generate(obj[k], indent_len))
          end
          @@loop -= 1

          return "{\n" << ret.join(",\n") << "\n#{indent * @@loop}}";
        else
          raise Exception.new("Unable to handle object of type #{obj.class.name} with value #{obj.inspect}")
      end

    end # end def
    private
    # simplify jsonification of standard types
    def simple_generate(obj)
      case obj
        when NilClass, :undef
          'null'
        when Fixnum, Float, TrueClass, FalseClass
          "#{obj}"
        else
          # Should be a string
          # keep string integers unquoted
          (obj =~ /\A[-]?\d+\z/) ? obj : obj.to_json
      end
    end

  end # end class

end # end module


module Puppet::Parser::Functions
  newfunction(:consul_sorted_json, :type => :rvalue, :doc => <<-EOS
This function takes unsorted hash and outputs JSON object making sure the keys are sorted.
Optionally you can pass 2 additional parameters, pretty generate and indent length.

*Examples:*

    -------------------
    -- UNSORTED HASH --
    -------------------
    unsorted_hash = {
      'client_addr' => '127.0.0.1',
      'bind_addr'   => '192.168.34.56',
      'start_join'  => [
        '192.168.34.60',
        '192.168.34.61',
        '192.168.34.62',
      ],
      'ports'       => {
        'rpc'   => 8567,
        'https' => 8500,
        'http'  => -1,
      },
    }

    -----------------
    -- SORTED JSON --
    -----------------

    consul_sorted_json(unsorted_hash)

    {"bind_addr":"192.168.34.56","client_addr":"127.0.0.1",
    "ports":{"http":-1,"https":8500,"rpc":8567},
    "start_join":["192.168.34.60","192.168.34.61","192.168.34.62"]}

    ------------------------
    -- PRETTY SORTED JSON --
    ------------------------
    Params: data <hash>, pretty <true|false>, indent <int>.

    consul_sorted_json(unsorted_hash, true, 4)

    {
        "bind_addr": "192.168.34.56",
        "client_addr": "127.0.0.1",
        "ports": {
            "http": -1,
            "https": 8500,
            "rpc": 8567
        },
        "start_join": [
            "192.168.34.60",
            "192.168.34.61",
            "192.168.34.62"
        ]
    }

    EOS
  ) do |args|

    unsorted_hash = args[0]      || {}
    pretty        = args[1]      || false
    indent_len    = args[2].to_i || 4

    if pretty
      return JSON.sorted_pretty_generate(unsorted_hash, indent_len) << "\n"
    else
      return JSON.sorted_generate(unsorted_hash)
    end
  end
end
