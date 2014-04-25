module SmoothOperator

  module RemoteCall

    class Base

      extend Forwardable

      attr_reader :response

      attr_accessor :object_class

      def initialize(response, object_class = nil)
        @response, @object_class = response, object_class
      end

      def_delegator :response, :status, :http_status

      def_delegators :response, :success?, :headers, :body

      def failure?
        http_status.between?(400, 499)
      end

      def error?
        http_status.between?(500, 599)
      end

      def parsed_response
        begin
          JSON.parse(body)
        rescue JSON::ParserError
          nil
        end
      end

      def status
        error? ? nil : success?
      end

    end

    class ConnectionFailed

      attr_reader :data, :status, :headers, :body

      def http_status; 0; end

      def error?; true; end

      def success?; false; end

      def failure?; false; end

    end

  end

end