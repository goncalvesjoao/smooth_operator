require 'active_model'

require "smooth_operator/naming"
require "smooth_operator/helpers"
require "smooth_operator/delegation"
require "smooth_operator/persistence"
require "smooth_operator/validations"
require "smooth_operator/translation"
require "smooth_operator/serialization"
require "smooth_operator/finder_methods"
require "smooth_operator/attribute_assignment"

module SmoothOperator
  
  class Base

    extend Naming
    extend Delegation
    extend Translation
    extend FinderMethods

    include Persistence
    include Validations
    include Serialization
    include AttributeAssignment
    include Delegation::MissingMethods

  end
  
end
