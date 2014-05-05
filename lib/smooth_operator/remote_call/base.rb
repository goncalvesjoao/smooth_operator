require "smooth_operator/remote_call/errors/base"
require "smooth_operator/remote_call/errors/timeout"
require "smooth_operator/remote_call/errors/connection_failed"

module SmoothOperator

  module RemoteCall

    class Base

      extend Forwardable

      attr_reader :response

      attr_accessor :object

      def_delegator :response, :status, :http_status

      def_delegators :response, :success?, :headers, :body

      alias :ok? :success?

      def initialize(response)
        @response = response
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

  end

end
