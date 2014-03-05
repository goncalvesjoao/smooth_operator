require "smooth_operator/operator/remote_call"

module SmoothOperator
  module HttpHandlers
    module Typhoeus

      class RemoteCall < SmoothOperator::Operator::RemoteCall

        attr_reader :request

        def initialize(request)
          @request = request
        end

        def timed_out?
          request.response.timed_out?
        end

        def parse_response
          begin
            @parse_response ||= ::HTTParty::Parser.call(@raw_response.body, :json)
          rescue
            nil
          end
        end

      end

    end

  end
end
