module SmoothOperator
  module Attributes

    class Normal < Base

      attr_reader :value

      def initialize(name, value, parent_object)
        @value = cast_to_type(name, value, parent_object)
      end

    end

  end
end
