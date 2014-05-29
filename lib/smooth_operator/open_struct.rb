require "smooth_operator/delegation"
require "smooth_operator/validations"
require "smooth_operator/model_schema"
require "smooth_operator/serialization"
require "smooth_operator/attribute_methods"
require "smooth_operator/attribute_assignment"

module SmoothOperator
  module OpenStruct

    class Base

      include Delegation
      include Validations
      include ModelSchema
      include Serialization
      include AttributeMethods
      include AttributeAssignment

      def self.strict_behaviour=(value)
        @strict_behaviour = value
      end

      def self.strict_behaviour
        Helpers.get_instance_variable(self, :strict_behaviour, false)
      end

    end

    class Dirty < Base

      dirty_attributes

    end

  end
end
