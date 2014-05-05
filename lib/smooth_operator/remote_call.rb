module SmoothOperator

  module RemoteCall

    class Base

      extend Forwardable

      attr_reader :response

      attr_accessor :object

      def_delegator :response, :status, :http_status

      def_delegators :response, :success?, :headers, :body

      def initialize(response, object_class = nil)
        @response, @object_class = response, object_class
      end


      def failure?
        http_status.between?(400, 499)
      end

      def error?
        http_status.between?(500, 599)
      end

      def parsed_response
        require 'json' unless defined? JSON
        
        begin
          JSON.parse(body)
        rescue JSON::ParserError
          nil
        end
      end

      def status
        error? ? nil : success?
      end

      def objects
        object.respond_to?(:length) ? object : []
      end

      def data
        object.nil? ? parsed_response : object
      end

    end

    class ConnectionFailed

      attr_reader :data, :object, :objects, :parsed_response, :status, :headers, :body

      def http_status; 0; end

      def error?; true; end

      def success?; false; end

      def failure?; false; end

    end

  end

end
