require 'httparty'

module SmoothOperator
  module ProtocolHandlers
    module HTTParty
    
      class Base

        HTTP_SUCCESS_CODES = [200, 201, 202, 203, 204]
    
        include ::HTTParty
        format :json

        def self.get(url, options, basic_auth_credentials)
          super(url, get_options(options, basic_auth_credentials))
        end

        def self.post(url, options, basic_auth_credentials)
          super(url, post_options(options, basic_auth_credentials))
        end

        def self.put(url, options, basic_auth_credentials)
          super(url, post_options(options, basic_auth_credentials))
        end

        def self.delete(url, options, basic_auth_credentials)
          super(url, post_options(options, basic_auth_credentials))
        end

        def self.successful_response?(response)
          response.blank? || HTTP_SUCCESS_CODES.include?(response.code)
        end

        private ################################ PRIVATE ##################

        def self.get_options(options, basic_auth_credentials)
        	options = { query: options }
          options.merge! get_basic_auth_credentials(basic_auth_credentials)
        end

        def self.post_options(options, basic_auth_credentials)
        	options = { body: options }
          options.merge! get_basic_auth_credentials(basic_auth_credentials)
        end

        def self.get_basic_auth_credentials(basic_auth_credentials)
          basic_auth_credentials.blank? ? {} : { basic_auth: basic_auth_credentials }
        end

      end
      
    end
  end
end
