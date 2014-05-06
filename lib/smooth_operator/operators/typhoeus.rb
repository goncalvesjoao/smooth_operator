require 'typhoeus'

module SmoothOperator

  module Operators

    class Typhoeus < Base

      def make_the_call
        set_basic_authentication

        # begin
          request = ::Typhoeus::Request.new(url, typhoeus_options)
          
          remote_call = RemoteCall::Base.new(request)

          hydra.queue(request)

          remote_call

        # rescue ::Faraday::Error::ConnectionFailed
        #   RemoteCall::Errors::ConnectionFailed.new(response)
        # rescue ::Faraday::Error::TimeoutError
        #   RemoteCall::Errors::Timeout.new(response)
        # end
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
        @typhoeus_options ||= {
          body: body,
          params: params,
          method: http_verb,
          headers: options[:headers],
          timeout: (options[:timeout] || operator_class.timeout)
        }
      end

      def hydra
        @hydra ||= operator_options[:hydra] || ::Typhoeus::Hydra::hydra
      end

    end

  end
end
