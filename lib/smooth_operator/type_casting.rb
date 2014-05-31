module SmoothOperator
  module TypeCasting

    # RIPPED FROM RAILS
    TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'on', 'ON'].to_set
    FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF'].to_set

    extend self

    def cast_to_type(name, value, parent_object)
      type, known_attribute, unknown_hash_class = extract_args(parent_object.class, name)

      return Helpers.duplicate(value) if known_attribute && type.nil?

      case value
      when Array
        value.map { |array_entry| cast_to_type(name, array_entry, parent_object) }
      when Hash
        type.nil? ? new_unknown_hash(value, unknown_hash_class, parent_object) : type.new(value, parent_object: parent_object)
      else
        convert(value, type)
      end
    end

    protected ##################### PROTECTED ########################

    def extract_args(parent_object_class, name)
      known_attribute, attribute_type = false, false

      if parent_object_class.respond_to?(:known_attribute?)
        known_attribute = parent_object_class.known_attribute?(name)
      end

      if parent_object_class.respond_to?(:attribute_type)
        attribute_type = parent_object_class.attribute_type(name)
      end

      [
        attribute_type,
        known_attribute,
        parent_object_class.unknown_hash_class
      ]
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

      TRUE_VALUES.include?(value) ? true : FALSE_VALUES.include?(value) ? false : nil
    end

    def to_int(string)
      return string if string.is_a?(Fixnum)

      to_float(string).to_i
    end

    def to_float(string)
      return string if string.is_a?(Float)

      return 0 if string.nil? || !(string.is_a?(String) || string.is_a?(Fixnum))

      value = string.to_s.gsub(',', '.').scan(/-*\d+[.]*\d*/).flatten.map(&:to_f).first

      value.nil? ? 0 : value
    end

    def new_unknown_hash(hash, unknown_hash_class, parent_object)
      if unknown_hash_class == :none
        hash
      else
        unknown_hash_class.new(cast_params(hash, unknown_hash_class, parent_object))
      end
    end

    private ################### PRIVATE #####################

    def cast_params(attributes, unknown_hash_class, parent_object)
      hash = {}

      attributes.each do |key, value|
        hash[key] = cast_to_type(key, value, parent_object)
      end

      hash
    end

  end

end
