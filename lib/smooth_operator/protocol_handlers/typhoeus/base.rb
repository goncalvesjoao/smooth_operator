require 'typhoeus'

module SmoothOperator
  module ProtocolHandlers
    module Typhoeus
    
      class Base
    
        def self.get(url, options, basic_auth_credentials)
          hydra = get_hydra_and_remove_it_from options
          options = { params: options, method: :get }.merge auth_credentials(basic_auth_credentials)

          make_request(url, options, hydra)
        end

        def self.post(url, options, basic_auth_credentials)
          hydra = get_hydra_and_remove_it_from options
          options = { params: options, method: :post }.merge auth_credentials(basic_auth_credentials)

          make_request(url, options, hydra)
        end

        def self.put(url, options, basic_auth_credentials)
          hydra = get_hydra_and_remove_it_from options
          options = { params: options, method: :put }.merge auth_credentials(basic_auth_credentials)

          make_request(url, options, hydra)
        end

        def self.delete(url, options, basic_auth_credentials)
          hydra = get_hydra_and_remove_it_from options
          options = { params: options, method: :delete }.merge auth_credentials(basic_auth_credentials)

          make_request(url, options, hydra)
        end

        def self.successful_response?(response)
          response.blank? || SmoothOperator::ProtocolHandlers.successful_response?(response.code)
        end
        
        private ###################### PRIVATE ##################

        def self.auth_credentials(basic_auth_credentials)        
          basic_auth_credentials.blank? ? {} : { userpwd: "#{basic_auth_credentials[:username]}:#{basic_auth_credentials[:password]}" }
        end
        
        def self.get_hydra_and_remove_it_from(options)
          options.delete(:hydra)
        end

        def self.make_request(url, options, hydra)
          if hydra.present?
            make_asynchronous_request(url, options, hydra)
          else
            make_synchronous_request(url, options)
          end
        end

        def self.make_synchronous_request(url, options)
          request = ::Typhoeus::Request.new(url, options)

          returning_response = SmoothOperator::Response.new(SmoothOperator::ProtocolHandlers::Typhoeus, request)

          request.on_complete { |response| returning_response.set_response response }
          request.run

          returning_response
        end

        def self.make_asynchronous_request(url, options, hydra)
          request = ::Typhoeus::Request.new(url, options)
          
          returning_response = SmoothOperator::Response.new(SmoothOperator::ProtocolHandlers::Typhoeus, request)

          hydra.queue(request)

          returning_response
        end

      end

    end
  end
end
