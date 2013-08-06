module SmoothOperator
  module HttpHandlers
    module Typhoeus

      class RemoteCall

        include SmoothOperator::Operator::RemoteCall

        attr_reader :request

        def initialize(request)
          @request = request
        end

        def parse_response(response)
          ::HTTParty::Parser.call(response.body, :json)
        end

        def successful_response?(response)
          response.blank? || super(code)
        end

      end

    end

  end
end
