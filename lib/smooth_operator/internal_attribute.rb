module SmoothOperator

  class InternalAttribute

    attr_reader :original_name, :original_value, :first_value, :value, :type

    def initialize(name, value, type)
      @original_name, @original_value, @type = name, value, type

      @first_value = set_value(value)
    end

    def set_value(new_value)
      @value = cast_to_type(new_value)
    end

    def changed?
      @first_value != @value
    end


    protected ######################## PROTECTED #####################

    def cast_to_type(_value)
      case _value
      when Array
        _value.map { |array_entry| InternalAttribute.new(original_name, array_entry, type).value }
      when Hash
        (type || OpenStruct).new(_value)
      else
        TypeConverter.convert(_value, type)
      end
    end

  end

end
