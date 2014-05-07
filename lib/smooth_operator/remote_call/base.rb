module SmoothOperator

  module RemoteCall

    class Base

      extend Forwardable

      attr_reader :response, :http_status, :body, :headers

      attr_accessor :object

      def initialize(response)
        @response = response
      end


      def success?
        http_status.between?(200, 299)
      end

      alias :ok? :success?

      def failure?
        http_status.between?(400, 499)
      end

      def error?
        http_status.between?(500, 599) || http_status == 0
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
        error? ? nil : success?
      end

      def objects
        object.respond_to?(:length) ? object : []
      end

      def data
        object.nil? ? parsed_response : object
      end

    end

  end

end
