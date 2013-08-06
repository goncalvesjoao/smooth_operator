module SmoothOperator
  module HttpHandlers
    module Typhoeus

      class RemoteCall << SmoothOperator::Operator::RemoteCall

        attr_reader :request

        def initialize(request)
          @request = request
        end

        def parse_response(response)
          ::HTTParty::Parser.call(response.body, :json)
        end

        def successful_response?(response)
          response.blank? || super(response)
        end

      end

    end

  end
end
