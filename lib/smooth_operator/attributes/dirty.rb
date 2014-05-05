require 'smooth_operator/type_converter'

module SmoothOperator
  module Attributes

    class Dirty

      attr_reader :original_name, :original_value, :first_value, :value, :type, :unknown_hash_class

      def initialize(name, value, type, unknown_hash_class)
        @original_name, @original_value, @type, @unknown_hash_class = name, value, type, unknown_hash_class

        @first_value = set_value(value)
      end

      def set_value(new_value)
        @value = TypeConverter.cast_to_type(original_name, new_value, type, self.class, unknown_hash_class)
      end

      def changed?
        @first_value != @value
      end

      def was
        @first_value
      end

    end

  end
end
