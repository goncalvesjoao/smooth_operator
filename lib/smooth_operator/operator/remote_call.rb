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

      def error?; !ok? && exception.present?; end

      def raw_response=(response)
        @raw_response = response
        @parsed_response = parse_response_and_set_exception_if_necessary
      end

      def response
        exception.present? ? false : @response
      end

      def ==(object_to_compare)
        response == object_to_compare
      end

      def <<(object)
        if response.is_a? Array
          response << object
        else
          response += object
        end
      end

      def respond_to?(symbol, include_priv = false)
        response.respond_to?(symbol, include_priv)
      end

      def to_s
        response
      end

      protected ####################### protected ##################

      def parse_response_and_set_exception_if_necessary
        @exception = successful_response? ? nil : SmoothOperator::Exceptions.raise_proper_exception(@raw_response, code)
        parse_response
      end

      private ####################### private ######################

      def method_missing(method, *args, &block)
        response.send(method, *args, &block)
      end

    end
    
  end
end
