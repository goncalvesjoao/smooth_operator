module SmoothOperator
  module Attributes

    class Base

      protected ##################### PROTECTED ########################

      def cast_to_type(name, value, parent_object)
        known_by_schema, type, unknown_hash_class = parent_object.known_by_schema?(name), parent_object.get_attribute_type(name), parent_object.class.unknown_hash_class

        return Helpers.duplicate(value) if known_by_schema && type.nil?

        case value
        when Array
          value.map { |array_entry| self.class.new(name, array_entry, parent_object).value }
        when Hash
          type.nil? ? new_unknown_hash(value, unknown_hash_class, parent_object) : type.new(value, parent_object: parent_object)
        else
          convert(value, type)
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
end
