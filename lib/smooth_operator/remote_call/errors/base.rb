module SmoothOperator
  module RemoteCall
    module Errors

      class Base

        attr_reader :response, :data, :object, :objects, :parsed_response, :status, :headers, :body

        def initialize(response)
          @response = response
        end

        def http_status; 0; end

        def error?; true; end

        def success?; false; end

        def failure?; false; end

      end

    end
  end
end
