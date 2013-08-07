require "smooth_operator/exceptions"

module SmoothOperator
  module Operator

    module RemoteCall

      def self.included(base)
        base.send(:attr_reader, :protocol_handler, :raw_response, :parsed_response, :exception)
        base.send(:attr_writer, :response)
      end

      HTTP_SUCCESS_CODES = [200, 201, 202, 203, 204]

      def parse_response # TO BE OVERWRITTEN IF NECESSARY
        @raw_response
      end
      
      def successful_response? # TO BE OVERWRITTEN IF NECESSARY
        @raw_response.blank? || HTTP_SUCCESS_CODES.include?(code)
      end

      def code # TO BE OVERWRITTEN IF NECESSARY
        @raw_response.code
      end

      def ok?; successful_response?; end

      def raw_response=(response)
        @raw_response = response
        @parsed_response = parse_response_and_set_exception_if_necessary
      end

      def response
        exception.present? ? false : @response
      end

      protected ####################### protected ##################

      def parse_response_and_set_exception_if_necessary
        @exception = successful_response? ? nil : SmoothOperator::Exceptions.raise_proper_exception(@raw_response, code)
        parse_response
      end

    end
    
  end
end
