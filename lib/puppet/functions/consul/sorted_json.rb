require 'json'

Puppet::Functions.create_function(:'consul::sorted_json') do
  # This function takes unsorted hash and outputs JSON object making sure the keys are sorted.
  # Optionally you can pass 2 additional parameters, pretty generate and indent length.
  #
  # *Examples:*
  #
  #     -------------------
  #     -- UNSORTED HASH --
  #     -------------------
  #     unsorted_hash = {
  #       'client_addr' => '127.0.0.1',
  #       'bind_addr'   => '192.168.34.56',
  #       'start_join'  => [
  #         '192.168.34.60',
  #         '192.168.34.61',
  #         '192.168.34.62',
  #       ],
  #       'ports'       => {
  #         'rpc'   => 8567,
  #         'https' => 8500,
  #         'http'  => -1,
  #       },
  #     }
  #
  #     -----------------
  #     -- SORTED JSON --
  #     -----------------
  #
  #     consul::sorted_json(unsorted_hash)
  #
  #     {"bind_addr":"192.168.34.56","client_addr":"127.0.0.1",
  #     "ports":{"http":-1,"https":8500,"rpc":8567},
  #     "start_join":["192.168.34.60","192.168.34.61","192.168.34.62"]}
  #
  #     ------------------------
  #     -- PRETTY SORTED JSON --
  #     ------------------------
  #     Params: data <hash>, pretty <true|false>, indent <int>.
  #
  #     consul::sorted_json(unsorted_hash, true, 4)
  #
  #     {
  #         "bind_addr": "192.168.34.56",
  #         "client_addr": "127.0.0.1",
  #         "ports": {
  #             "http": -1,
  #             "https": 8500,
  #             "rpc": 8567
  #         },
  #         "start_join": [
  #             "192.168.34.60",
  #             "192.168.34.61",
  #             "192.168.34.62"
  #         ]
  #     }
  #
  def sorted_json(unsorted_hash = {}, pretty = false, indent_len = 4)
    quoted = false
    # simplify jsonification of standard types
    simple_generate = lambda do |obj|
      case obj
        when NilClass, :undef
          'null'
        when Integer, Float, TrueClass, FalseClass
          if quoted then
            "\"#{obj}\""
          else
            "#{obj}"
          end
        else
          # Should be a string
          # keep string integers unquoted
          (obj =~ /\A[-]?(0|[1-9]\d*)\z/ && !quoted) ? obj : obj.to_json
      end
    end

    sorted_generate = lambda do |obj|
      case obj
        when NilClass, :undef, Integer, Float, TrueClass, FalseClass, String
          return simple_generate.call(obj)
        when Array
          arrayRet = []
          obj.each do |a|
            arrayRet.push(sorted_generate.call(a))
          end
          return "[" << arrayRet.join(',') << "]";
        when Hash
          ret = []
          obj.keys.sort.each do |k|
            if k =~ /\A(node_meta|meta|tags)\z/ then
              quoted = true
            elsif k =~ /\A(weights)\z/ then
              quoted = false
            end
            ret.push(k.to_json << ":" << sorted_generate.call(obj[k]))
          end
          quoted = false
          return "{" << ret.join(",") << "}";
        else
          raise Exception.new("Unable to handle object of type #{obj.class.name} with value #{obj.inspect}")
      end
    end

    sorted_pretty_generate = lambda do |obj, indent_len=4, level=0|
      # Indent length
      indent = " " * indent_len

      case obj
        when NilClass, :undef, Integer, Float, TrueClass, FalseClass, String
          return simple_generate.call(obj)
        when Array
          arrayRet = []

          # We need to increase the level count before #each so the objects inside are indented twice.
          # When we come out of #each we decrease the level count so the closing brace lines up properly.
          #
          # If you start with level = 1, the count will be as follows
          #
          # "start_join": [     <-- level == 1
          #   "192.168.50.20",  <-- level == 2
          #   "192.168.50.21",  <-- level == 2
          #   "192.168.50.22"   <-- level == 2
          # ] <-- closing brace <-- level == 1
          #
          level += 1
          obj.each do |a|
            arrayRet.push(sorted_pretty_generate.call(a, indent_len, level))
          end
          level -= 1

          return "[\n#{indent * (level + 1)}" << arrayRet.join(",\n#{indent * (level + 1)}") << "\n#{indent * level}]";

        when Hash
          ret = []

          # This level works in a similar way to the above
          level += 1
          obj.keys.sort.each do |k|
            if k =~ /\A(node_meta|meta|tags)\z/ then
              quoted = true
            elsif k =~ /\A(weights)\z/ then
              quoted = false
            end
            ret.push("#{indent * level}" << k.to_json << ": " << sorted_pretty_generate.call(obj[k], indent_len, level))
          end
          level -= 1

          quoted = false
          return "{\n" << ret.join(",\n") << "\n#{indent * level}}";
        else
          raise Exception.new("Unable to handle object of type #{obj.class.name} with value #{obj.inspect}")
      end
    end

    if pretty
      return sorted_pretty_generate.call(unsorted_hash, indent_len) << "\n"
    else
      return sorted_generate.call(unsorted_hash)
    end
  end
end
