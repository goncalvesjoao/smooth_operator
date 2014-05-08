module SmoothOperator
  module RemoteCall
    module Errors

      class ConnectionFailed < Base

        def initialize(response)
          super
          @http_status = 0
        end

        def connection_failed?
          true
        end

      end

    end
  end
end
