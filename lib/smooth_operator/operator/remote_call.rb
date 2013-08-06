require "smooth_operator/exceptions"

module SmoothOperator
  class RemoteCall

    attr_reader :protocol_handler, :raw_response, :parsed_response

    attr_accessor :response

    def parse_response(response) # TO BE DEFINED
      response
    end

    def successful_response?(code) # TO BE DEFINED
      RemoteCall.successful_response?(code)
    end

    def get_response_code(response) # TO BE DEFINED
      response.code
    end

    protected ####################### protected ##################

    HTTP_SUCCESS_CODES = [200, 201, 202, 203, 204]    
    def self.successful_response?(code)
      HTTP_SUCCESS_CODES.include?(code)
    end

    def raw_response=(response)
      @raw_response = response
      @parsed_response = parse_response_or_raise_proper_exception(@raw_response)
    end

    def parse_response_or_raise_proper_exception(response)
      if successful_response?(response)
        parse_response(response)
      else
        SmoothOperator::Exceptions.raise_proper_exception(response, get_response_code(response))
      end
    end

  end
end
