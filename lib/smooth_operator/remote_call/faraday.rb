module SmoothOperator

  module RemoteCall

    class Faraday < Base

      def initialize(response)
        @response = response

        @body = response.body
        @headers = response.headers
        @http_status = response.status
      end

    end

  end

end
