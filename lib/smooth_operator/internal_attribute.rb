require 'smooth_operator/type_converter'

module SmoothOperator

  class InternalAttribute

    attr_reader :original_name, :original_value, :first_value, :value, :type, :turn_unknown_hash_to_open_struct

    def initialize(name, value, type, turn_to_open_struct = nil)
      @original_name, @original_value, @type = name, value, type
      
      @turn_unknown_hash_to_open_struct = turn_to_open_struct.nil? ? true : turn_to_open_struct

      @first_value = set_value(value)
    end

    def set_value(new_value)
      @value = cast_to_type(new_value)
    end

    def changed?
      @first_value != @value
    end

    def was
      @first_value
    end


    protected ######################## PROTECTED #####################

    def cast_to_type(_value)
      case _value
      when Array
        _value.map { |array_entry| InternalAttribute.new(original_name, array_entry, type, turn_unknown_hash_to_open_struct).value }
      when Hash
        if turn_unknown_hash_to_open_struct
          (type || OpenStruct).new(_value)
        else
          type.nil? ? _value : type.new(_value)
        end
      else
        TypeConverter.convert(_value, type)
      end
    end

  end

end
