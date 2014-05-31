require "smooth_operator/delegation"
require "smooth_operator/validations"
require "smooth_operator/resource_name"
require "smooth_operator/serialization"
require "smooth_operator/internal_data"
require "smooth_operator/attribute_assignment"

module SmoothOperator
  class OpenStruct

    extend ResourceName

    include Delegation
    include Validations
    include InternalData
    include Serialization
    include AttributeAssignment

  end
end
