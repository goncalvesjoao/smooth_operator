module SmoothOperator

  module RemoteCall

    class Typhoeus < Base

      def initialize(response)
        @response = response

        @body = response.body
        @http_status = response.code
        @headers = response.headers_hash
      end

    end

  end

end
