require 'smooth_operator/type_converter'

module SmoothOperator
  module Attributes

    class Base

      attr_reader :value

      def initialize(name, value, type, unknown_hash_class)
        @value = TypeConverter.cast_to_type(name, value, type, self.class, unknown_hash_class)
      end

    end

  end
end
