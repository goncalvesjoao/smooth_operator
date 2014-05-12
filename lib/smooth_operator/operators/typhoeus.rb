require 'typhoeus'
require "smooth_operator/remote_call/typhoeus"

module SmoothOperator

  module Operators

    module Typhoeus

      extend self

      def make_the_call(http_verb, resource_path, params, body, options)
        request = ::Typhoeus::Request.new *typhoeus_request_args(http_verb, resource_path, params, body, options)
        
        hydra = options[:hydra] || ::Typhoeus::Hydra::hydra

        _remote_call = nil

        hydra.queue(request)

        request.on_complete do |typhoeus_response|          
          _remote_call = remote_call(typhoeus_response)

          yield(_remote_call) if block_given?
        end

        hydra.run if Helpers.blank?(options[:hydra])

        _remote_call
      end


      protected ################ PROTECTED ################

      def typhoeus_request_args(http_verb, relative_path, params, body, options)
        [url(options, relative_path), build_typhoeus_options(http_verb, params, body, options)]
      end

      def remote_call(typhoeus_response)
        if typhoeus_response.return_code == :couldnt_connect
          RemoteCall::Errors::ConnectionFailed
        elsif typhoeus_response.timed_out?
          RemoteCall::Errors::Timeout
        else
          RemoteCall::Typhoeus
        end.new(typhoeus_response)
      end


      private ################### PRIVATE ###############

      def build_typhoeus_options(http_verb, params, body, options)
        typhoeus_options = { method: http_verb, headers: options[:headers].merge({ "Content-type" => "application/x-www-form-urlencoded" }) }

        typhoeus_options[:timeout] = options[:timeout] if Helpers.present?(options[:timeout])

        typhoeus_options[:body] = body if Helpers.present?(body)
        
        typhoeus_options[:params] = params if Helpers.present?(params)

        typhoeus_options[:userpwd] = "#{options[:endpoint_user]}:#{options[:endpoint_pass]}" if Helpers.present?(options[:endpoint_user])

        typhoeus_options
      end

      def url(options, relative_path)
        url = options[:endpoint]
        
        slice = url[-1] != '/' ? '/' : ''

        url = "#{url}#{slice}#{relative_path}" if Helpers.present?(relative_path)
      end

    end

  end
end
