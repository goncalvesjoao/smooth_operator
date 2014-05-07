require 'typhoeus'
require "smooth_operator/remote_call/typhoeus"

module SmoothOperator

  module Operators

    class Typhoeus < Base

      def make_the_call
        set_basic_authentication

        request = ::Typhoeus::Request.new(url, typhoeus_options)
        
        remote_call = {}

        # hydra.queue(request)

        request.on_complete do |typhoeus_response|
          remote_call_class = if typhoeus_response.return_code == :couldnt_connect
            RemoteCall::Errors::ConnectionFailed
          elsif typhoeus_response.timed_out?
            RemoteCall::Errors::Timeout
          else
            RemoteCall::Typhoeus
          end
          
          remote_call = remote_call_class.new(typhoeus_response)

          yield(remote_call) if block_given?
        end

        # hydra.run

        request.run

        remote_call
      end


      protected ################ PROTECTED ################

      def set_basic_authentication
        typhoeus_options[:userpwd] = "#{endpoint_user}:#{endpoint_pass}" if Helpers.present?(endpoint_user)
      end

      def url
        url = (options[:endpoint] || operator_class.endpoint)
        
        slice = url[-1] != '/' ? '/' : ''

        url = "#{url}#{slice}#{relative_path}" if Helpers.present?(relative_path)
      end

      def typhoeus_options
        return @typhoeus_options if defined?(@typhoeus_options)
        
        @typhoeus_options = { method: http_verb, headers: options[:headers].merge({ "Content-type" => "application/x-www-form-urlencoded" }) }

        timeout = (options[:timeout] || operator_class.timeout)

        @typhoeus_options[:timeout] = timeout if Helpers.present?(timeout)

        @typhoeus_options[:body] = body if Helpers.present?(body)
        # @typhoeus_options[:params] = params if Helpers.present?(params)

        @typhoeus_options
      end

      def hydra
        @hydra ||= operator_options[:hydra] || ::Typhoeus::Hydra::hydra
      end

    end

  end
end
