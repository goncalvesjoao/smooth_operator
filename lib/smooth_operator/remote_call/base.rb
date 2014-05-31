module SmoothOperator

  module RemoteCall

    class Base

      extend Forwardable

      attr_reader :response, :http_status, :body, :headers

      attr_accessor :object

      def initialize(response)
        @response = response
      end

      def ok?
        http_status.between?(200, 299) || http_status == 304
      end

      def not_processed?
        http_status == 422
      end

      def error?
        !ok? && !not_processed?
      end

      def client_error?
        http_status.between?(400, 499)
      end

      def server_error?
        http_status.between?(500, 599) || http_status == 0
      end

      def not_found?
        http_status == 404
      end

      def timeout?
        false
      end

      def connection_failed?
        false
      end

      def parsed_response
        return nil if body.nil?

        require 'json' unless defined? JSON

        begin
          JSON.parse(body)
        rescue JSON::ParserError
          nil
        end
      end

      def status
        error? ? nil : ok?
      end

      def data
        object.nil? ? parsed_response : object
      end

    end
  end
end
