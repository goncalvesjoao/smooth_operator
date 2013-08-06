require 'httparty'

module SmoothOperator
  module ProtocolHandlers
    module HTTParty
    
      class Base
    
        include ::HTTParty
        format :json

        def self.get(url, options, basic_auth_credentials)
          options = { query: options }.merge auth_credentials(basic_auth_credentials)
          super(url, options)
        end

        def self.post(url, options, basic_auth_credentials)
          options = { body: options }.merge auth_credentials(basic_auth_credentials)
          super(url, options)
        end

        def self.put(url, options, basic_auth_credentials)
          options = { body: options }.merge auth_credentials(basic_auth_credentials)
          super(url, options)
        end

        def self.delete(url, options, basic_auth_credentials)
          options = { body: options }.merge auth_credentials(basic_auth_credentials)
          super(url, options)
        end

        def self.successful_response?(response)
          response.blank? || SmoothOperator::ProtocolHandlers.successful_response?(response.code)
        end

        private ################################ PRIVATE ##################

        def self.auth_credentials(basic_auth_credentials)
          basic_auth_credentials.blank? ? {} : { basic_auth: basic_auth_credentials }
        end

      end
      
    end
  end
end
