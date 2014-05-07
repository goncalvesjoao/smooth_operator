module SmoothOperator
  module Attributes

    class Dirty < Base

      attr_reader :original_name, :original_value, :first_value, :value, :type

      def initialize(name, value, type, unknown_hash_class, parent_object)
        @original_name, @original_value, @type = name, value, type

        @first_value = set_value(value, unknown_hash_class, parent_object)
      end

      def set_value(new_value, unknown_hash_class, parent_object)
        @value = cast_to_type(original_name, new_value, type, unknown_hash_class, parent_object)
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
