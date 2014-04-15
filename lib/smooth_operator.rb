require "smooth_operator/version"

require 'active_model'

require "smooth_operator/attribute_assignment"
require "smooth_operator/delegation"
require "smooth_operator/helpers"
require "smooth_operator/naming"
require "smooth_operator/record"
require "smooth_operator/translation"
require "smooth_operator/serialization"

module SmoothOperator
  
  class Base

    include AttributeAssignment
    include Record
    include Serialization

    extend Naming
    extend Delegation
    extend Translation

  end
  
end
