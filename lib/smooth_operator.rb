# require 'active_model'

require "smooth_operator/naming"
require "smooth_operator/helpers"
require "smooth_operator/operator"
require "smooth_operator/remote_call"
require "smooth_operator/persistence"
require "smooth_operator/translation"
require "smooth_operator/open_struct"
require "smooth_operator/finder_methods"

module SmoothOperator
  
  class Base < OpenStruct

    extend Naming if defined? ActiveModel
    extend Translation if defined? I18n

    extend Operator
    extend FinderMethods

    include Persistence

  end
  
end
