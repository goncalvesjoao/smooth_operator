module SmoothOperator

  module ParamsEncoder

    def self.escape(s)
      Faraday::NestedParamsEncoder.escape(s)
    end

    def self.unescape(s)
      Faraday::NestedParamsEncoder.unescape(s)
    end

    def self.decode(query)
      Faraday::NestedParamsEncoder.decode(query)
    end

    def self.encode(params)
      return nil if params.nil?

      if !params.is_a?(Array)
        if !params.respond_to?(:to_hash)
          raise TypeError,
            "Can't convert #{params.class} into Hash."
        end
        params = params.to_hash
        params = params.map do |key, value|
          key = key.to_s if key.kind_of?(Symbol)
          [key, value]
        end
        # Useful default for OAuth and caching.
        # Only to be used for non-Array inputs. Arrays should preserve order.
        params.sort!
      end

      # The params have form [['key1', 'value1'], ['key2', 'value2']].
      buffer = ''
      params.each do |parent, value|
        encoded_parent = escape(parent)
        buffer << "#{_build_nested_query(encoded_parent, value)}&"
      end
      return buffer.chop
    end


    protected ##################### PROTECTED ####################

    def self._old_build_nested_query(value, prefix = nil)
      case value
      when Array
        value.map { |v| _build_nested_query(v, "#{prefix}[]=") }.join("&")
      when Hash
        value.map { |k, v|
          _build_nested_query(v, prefix ? "#{prefix}#{escape(k)}" : escape(k))
        }.join("&")
      when NilClass
        prefix
      else
        raise ArgumentError, "value must be a Hash" if prefix.nil?
        "#{prefix}=#{escape(value)}"
      end
    end

    def self._build_nested_query(parent, value)
      if value.is_a?(Hash)
        value = value.map do |key, val|
          key = escape(key)
          [key, val]
        end
        value.sort!
        buffer = ""
        value.each do |key, val|
          new_parent = "#{parent}%5B#{key}%5D"
          buffer << "#{_build_nested_query(new_parent, val)}&"
        end
        return buffer.chop
      elsif value.is_a?(Array)
        buffer = ""
        value.each_with_index do |val, i|
          new_parent = "#{parent}[]"
          buffer << "#{_build_nested_query(new_parent, val)}&"
        end
        binding.pry
        return buffer.chop
      else
        encoded_value = escape(value)
        return "#{parent}=#{encoded_value}"
      end
    end

  end

end
