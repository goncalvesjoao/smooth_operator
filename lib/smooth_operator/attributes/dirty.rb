module SmoothOperator
  module Attributes

    class Dirty < Base

      attr_reader :original_name, :original_value, :first_value, :value

      def initialize(name, value, parent_object)
        @original_name, @original_value = name, value

        @first_value = set_value(value, parent_object)
      end

      def set_value(new_value, parent_object)
        @value = cast_to_type(original_name, new_value, parent_object)
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
