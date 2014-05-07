module SmoothOperator
  module Attributes

    class Normal < Base

      attr_reader :value

      def initialize(name, value, type, unknown_hash_class, parent_object)
        @value = cast_to_type(name, value, type, unknown_hash_class, parent_object)
      end

    end

  end
end
