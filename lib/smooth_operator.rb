# require 'active_model'

require "smooth_operator/naming"
require "smooth_operator/helpers"
require "smooth_operator/web_agent"
require "smooth_operator/delegation"
require "smooth_operator/remote_call"
require "smooth_operator/persistence"
require "smooth_operator/validations"
require "smooth_operator/translation"
require "smooth_operator/model_schema"
require "smooth_operator/serialization"
require "smooth_operator/finder_methods"
require "smooth_operator/attribute_assignment"

module SmoothOperator
  
  class Base

    extend Naming if defined? ActiveModel
    extend Translation if defined? I18n

    extend WebAgent
    extend Delegation
    extend FinderMethods

    include Validations
    include ModelSchema
    include Persistence
    include Serialization
    include AttributeAssignment
    include Delegation::MissingMethods

  end
  
end
