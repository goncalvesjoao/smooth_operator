require "smooth_operator/delegation"
require "smooth_operator/validations"
require "smooth_operator/model_schema"
require "smooth_operator/serialization"
require "smooth_operator/attribute_assignment"

module SmoothOperator
  module OpenStruct

    class Base

      include Delegation
      include Validations
      include ModelSchema
      include Serialization
      include AttributeAssignment

    end

    class Dirty < Base

      dirty_attributes
      
    end

  end
end
