module SmoothOperator
  module HttpHandlers
    module Typhoeus

      class RemoteCall

        include SmoothOperator::Operator::RemoteCall

        attr_reader :request

        def initialize(request)
          @request = request
        end

        def parse_response
          ::HTTParty::Parser.call(@raw_response.body, :json)
        end

      end

    end

  end
end
