module SmoothOperator

  module RemoteCall

    class Base

      extend Forwardable

      attr_reader :response

      def initialize(response)
        @response = response
      end

      def_delegator :response, :status, :http_status

      def_delegators :response, :success?, :headers, :body

      def failure?
        http_status.between?(400, 499)
      end

      def error?
        http_status.between?(500, 599)
      end

      def data
        require 'json' unless defined?(::JSON)

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