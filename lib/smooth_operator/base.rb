require "smooth_operator/core"
require "smooth_operator/operator/base"
require "smooth_operator/operator/orm"

require "smooth_operator/http_handlers/typhoeus/base"
require "smooth_operator/http_handlers/typhoeus/orm"

module SmoothOperator

  class Base < OpenStruct
    include SmoothOperator::Core
    include SmoothOperator::Operator::Base
    include SmoothOperator::Operator::ORM

    protected ################### PROTECTED ###################

    def self.http_handler_base
      SmoothOperator::HttpHandlers::Typhoeus::Base
    end

    def self.http_handler_orm
      SmoothOperator::HttpHandlers::Typhoeus::ORM
    end

    def http_handler_orm
      self.class.http_handler_orm
    end

  end

end
