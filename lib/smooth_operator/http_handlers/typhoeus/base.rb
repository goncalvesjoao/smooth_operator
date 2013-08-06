require 'typhoeus'

module SmoothOperator
  module HttpHandlers
    module Typhoeus
    
      class Base
    
        def self.get(url, options, basic_auth_credentials)
          make_request(url, options, basic_auth_credentials, :get)
        end

        def self.post(url, options, basic_auth_credentials)
          make_request(url, options, basic_auth_credentials, :post)
        end

        def self.put(url, options, basic_auth_credentials)
          make_request(url, options, basic_auth_credentials, :put)
        end

        def self.delete(url, options, basic_auth_credentials)
          make_request(url, options, basic_auth_credentials, :delete)
        end
        
        private ###################### PRIVATE ##################

        def self.auth_credentials(basic_auth_credentials)        
          basic_auth_credentials.blank? ? {} : { userpwd: "#{basic_auth_credentials[:username]}:#{basic_auth_credentials[:password]}" }
        end
        
        def self.get_hydra_and_remove_it_from(options)
          options.delete(:hydra)
        end

        def self.make_request(url, options, basic_auth_credentials, http_verb)
          hydra = get_hydra_and_remove_it_from options
          options = { params: options, method: http_verb }.merge auth_credentials(basic_auth_credentials)

          if hydra.present?
            make_asynchronous_request(url, options, hydra)
          else
            make_synchronous_request(url, options)
          end
        end

        def self.make_synchronous_request(url, options)
          request = ::Typhoeus::Request.new(url, options)

          remote_call = RemoteCall.new(request)

          request.on_complete { |response| remote_call.raw_response = response }
          request.run

          remote_call
        end

        def self.make_asynchronous_request(url, options, hydra)
          request = ::Typhoeus::Request.new(url, options)
          
          remote_call = RemoteCall.new(request)

          hydra.queue(request)

          remote_call
        end

      end

    end
  end
end
