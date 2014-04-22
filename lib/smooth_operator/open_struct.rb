require "smooth_operator/delegation"
require "smooth_operator/validations"
require "smooth_operator/model_schema"
require "smooth_operator/serialization"
require "smooth_operator/attribute_assignment"

module SmoothOperator

  class OpenStruct

    include Delegation
    include Validations
    include ModelSchema
    include Serialization
    include AttributeAssignment

  end

end
