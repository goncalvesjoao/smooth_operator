require "smooth_operator/response"

require "smooth_operator/protocol_handlers/httparty/base"
require "smooth_operator/protocol_handlers/httparty/orm"

require "smooth_operator/protocol_handlers/typhoeus/base"
require "smooth_operator/protocol_handlers/typhoeus/orm"

module SmoothOperator
  module ProtocolHandlers

    extend self

    HTTP_SUCCESS_CODES = [200, 201, 202, 203, 204]
    
    def successful_response?(code)
      HTTP_SUCCESS_CODES.include?(code)
    end

  end
end
