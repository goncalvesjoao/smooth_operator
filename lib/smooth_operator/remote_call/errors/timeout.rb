module SmoothOperator
  module RemoteCall
    module Errors

      class Timeout < Base

        def initialize(response)
          super
          @http_status = 0
        end

        def timeout?
          true
        end

      end

    end
  end
end
