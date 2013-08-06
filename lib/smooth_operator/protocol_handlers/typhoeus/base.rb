require 'typhoeus'

module SmoothOperator
  module ProtocolHandlers
    module Typhoeus
    
      class Base
    
        def self.get(url, options, basic_auth_credentials)
          hydra = get_hydra_and_remove_it_from options
          options = get_options(options, basic_auth_credentials)
          make_request(url, options, hydra)
        end

        def self.post(url, options, basic_auth_credentials)
          hydra = get_hydra_and_remove_it_from options
          options = post_options(options, basic_auth_credentials)
          make_request(url, options, hydra)
        end

        def self.put(url, options, basic_auth_credentials)
          hydra = get_hydra_and_remove_it_from options
          options = put_options(options, basic_auth_credentials)
          make_request(url, options, hydra)
        end

        def self.delete(url, options, basic_auth_credentials)
          hydra = get_hydra_and_remove_it_from options
          options = delete_options(options, basic_auth_credentials)
          make_request(url, options, hydra)
        end

        def self.successful_response?(response)
          response.blank? || SmoothOperator::ProtocolHandlers.successful_response?(response.code)
        end
        

        private ###################### PRIVATE ##############

        def self.get_options(options, basic_auth_credentials)
          options = { params: options, method: :get }
          options.merge! get_basic_auth_credentials(basic_auth_credentials)
        end

        def self.post_options(options, basic_auth_credentials)
          options = { body: options, method: :post }
          options.merge! get_basic_auth_credentials(basic_auth_credentials)
        end

        def self.put_options(options, basic_auth_credentials)
          options = { body: options, method: :put }
          options.merge! get_basic_auth_credentials(basic_auth_credentials)
        end

        def self.delete_options(options, basic_auth_credentials)
          options = { body: options, method: :delete }
          options.merge! get_basic_auth_credentials(basic_auth_credentials)
        end

        def self.get_basic_auth_credentials(basic_auth_credentials)        
          basic_auth_credentials.blank? ? {} : { userpwd: "#{basic_auth_credentials[:username]}:#{basic_auth_credentials[:password]}" }
        end
        
        def self.get_hydra_and_remove_it_from(options)
          options.delete(:hydra)
        end

        def self.make_request(url, options, hydra)
          if hydra.present?
            make_asynchronous_request(url, hydra, options)
          else
            make_synchronous_request(url, options)
          end
        end

        def self.make_synchronous_request(url, options)
          returning_response = nil

          request = ::Typhoeus::Request.new(url, options)
          request.on_complete { |response| returning_response = response }
          request.run

          returning_response
        end

        def self.make_asynchronous_request(url, hydra, options)
          request = ::Typhoeus::Request.new(url, options)
          hydra.queue(request)
          request
        end

      end

    end
  end
end
