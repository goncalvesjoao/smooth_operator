require 'typhoeus'
require "smooth_operator/http_handlers/typhoeus/remote_call"

module SmoothOperator
  module HttpHandlers
    module Typhoeus
    
      class Base
    
        def self.make_the_call(http_verb, url, options, basic_auth_credentials)
          hydra = extract_hydra_from options
          typhoeus_options = extract_typhoeus_from options

          options = { (http_verb == :get ? :params : :body) => options, :method => http_verb, :headers => { "Content-type" => "application/x-www-form-urlencoded" } }

          options = options.merge(auth_credentials(basic_auth_credentials)).merge(typhoeus_options)
          
          if hydra.present?
            make_asynchronous_request(url, options, hydra)
          else
            make_synchronous_request(url, options)
          end
        end
        
        private ###################### PRIVATE ##################

        def self.auth_credentials(basic_auth_credentials)        
          basic_auth_credentials.blank? ? {} : { userpwd: "#{basic_auth_credentials[:username]}:#{basic_auth_credentials[:password]}" }
        end
        
        def self.extract_hydra_from(options)
          options.delete(:hydra)
        end

        def self.extract_typhoeus_from(options)
          known_typhoeus_options = [:timeout, :connecttimeout, :timeout_ms, :connecttimeout_ms]

          typhoeus_options = options.slice(*known_typhoeus_options).dup
          
          known_typhoeus_options.each { |key| options.delete(key) }

          typhoeus_options
        end

        def self.make_synchronous_request(url, options)
          hydra = ::Typhoeus::Hydra::hydra
          remote_call = make_asynchronous_request(url, options, hydra)

          remote_call.request.on_complete do |response|
            remote_call.raw_response = response
            remote_call.response = remote_call.parsed_response
          end

          hydra.run
          remote_call
        end

        def self.make_asynchronous_request(url, options, hydra)
          request = ::Typhoeus::Request.new(url, options)
          
          remote_call = SmoothOperator::HttpHandlers::Typhoeus::RemoteCall.new(request)

          hydra.queue(request)

          remote_call
        end

      end

    end
  end
end
