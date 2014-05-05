module SmoothOperator

  module TypeConverter

    extend self

    def cast_to_type(name, value, type, array_class, unknown_hash_class)
      case value
      when Array
        value.map { |array_entry| array_class.new(name, array_entry, type, unknown_hash_class).value }
      when Hash
        type.nil? ? new_unknown_hash(value, array_class, unknown_hash_class) : type.new(value)
      else
        TypeConverter.convert(value, type)
      end
    end

    def convert(value, type)
      case type

      when :string, :text, String
        value.to_s
      
      when :int, :integer, Integer, Fixnum
        to_int(value)

      when :date, Date
        to_date(value)

      when :float, Float
        to_float(value)

      when :bool, :boolean
        to_boolean(value)

      when :datetime, :date_time, DateTime
        to_datetime(value)

      else
        Helpers.duplicate(value)
      end
    end

    def to_int(string)
      return string if string.is_a?(Fixnum)

      to_float(string).to_i
    end

    def to_date(string)
      return string if string.is_a?(Date)

      Date.parse(string) rescue nil
    end

    def to_datetime(string)
      return string if string.is_a?(DateTime)

      DateTime.parse(string) rescue nil
    end

    def to_boolean(string)
      value = string.to_s.downcase

      ['1', 'true'].include?(value) ? true : ['0', 'false'].include?(value) ? false : nil
    end

    def to_float(string)
      return string if string.is_a?(Float)

      return 0 if string.nil? || !string.is_a?(String)
      
      value = string.scan(/-*\d+[,.]*\d*/).flatten.map(&:to_f).first

      value.nil? ? 0 : value
    end


    protected ################### PROTECTED #####################

    def new_unknown_hash(hash, array_class, unknown_hash_class)
      if unknown_hash_class == :none
        hash
      else
        unknown_hash_class.new(cast_params(hash, array_class, unknown_hash_class))
      end
    end


    private ################### PRIVATE #####################

    def cast_params(attributes, array_class, unknown_hash_class)
      hash = {}

      attributes.each do |key, value|
        hash[key] = cast_to_type(key, value, nil, array_class, unknown_hash_class)
      end

      hash
    end
  
  end
  
end
