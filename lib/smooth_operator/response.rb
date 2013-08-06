require "smooth_operator/exceptions"

module SmoothOperator
  class Response

    attr_reader :protocol_handler, :request, :raw_response, :parsed_response

    attr_accessor :response

    def initialize(protocol_handler, request = nil)
      @protocol_handler = protocol_handler
      @request = request
    end

    def set_response(response)
      @raw_response = response
      @parsed_response = parse_response_or_raise_proper_exception(@raw_response)
    end

    def parse_response(response)
      @protocol_handler::ORM.parse_response(response)
    end

    def parse_response_or_raise_proper_exception(response)
      if @protocol_handler::Base.successful_response?(response)
        parse_response(response)
      else
        SmoothOperator::Exceptions.raise_proper_exception(response, response.code)
      end
    end

  end
end
