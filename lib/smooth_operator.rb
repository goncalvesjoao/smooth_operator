require "smooth_operator/version"
require "smooth_operator/helpers"
require "smooth_operator/operator"
require "smooth_operator/persistence"
require "smooth_operator/translation"
require "smooth_operator/open_struct"
require "smooth_operator/finder_methods"

module SmoothOperator
  
  class Base < OpenStruct::Base

    extend FinderMethods
    extend Translation if defined? I18n

    include Operator
    include Persistence
    include FinderMethods

    self.strict_behaviour = true

  end
  
end
