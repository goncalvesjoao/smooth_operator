require "smooth_operator/exceptions"

module SmoothOperator
  module Operator

    module RemoteCall

      def self.included(base)
        base.extend(ClassMethods)
        base.send(:attr_reader, :protocol_handler, :raw_response, :parsed_response)
        base.send(:attr_accessor, :response)
      end

      module ClassMethods

        HTTP_SUCCESS_CODES = [200, 201, 202, 203, 204]    
        def successful_response?(code)
          HTTP_SUCCESS_CODES.include?(code)
        end

      end

      def parse_response(response) # TO BE OVERWRITTEN
        response
      end

      def successful_response?(code) # TO BE OVERWRITTEN
        self.class.successful_response?(code)
      end

      def code # TO BE OVERWRITTEN
        @raw_response.code
      end

      def raw_response=(response)
        @raw_response = response
        @parsed_response = parse_response_or_raise_proper_exception
      end

      protected ####################### protected ##################

      def parse_response_or_raise_proper_exception
        if successful_response?(@raw_response)
          parse_response(@raw_response)
        else
          SmoothOperator::Exceptions.raise_proper_exception(@raw_response, code)
        end
      end

    end
    
  end
end
