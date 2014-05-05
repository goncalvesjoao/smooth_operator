# require 'active_model'

require "smooth_operator/version"
require "smooth_operator/helpers"
require "smooth_operator/operator"
require "smooth_operator/remote_call"
require "smooth_operator/persistence"
require "smooth_operator/translation"
require "smooth_operator/open_struct"
require "smooth_operator/finder_methods"

module SmoothOperator
  
  class Base < OpenStruct::Base

    extend Operator
    extend FinderMethods
    extend Translation if defined? I18n

    include Persistence

    attr_reader :last_remote_call

  end
  
end
