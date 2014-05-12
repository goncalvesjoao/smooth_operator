require 'faraday'
require 'typhoeus/adapters/faraday'
require "smooth_operator/remote_call/faraday"

module SmoothOperator

  module Operators

    module Faraday

      extend self

      # def generate_parallel_connection
      #   generate_connection(:typhoeus)
      # end

      def generate_connection(adapter = nil, options = nil)
        adapter ||= :net_http

        ::Faraday.new(url: options[:endpoint]) do |builder|
          builder.options[:timeout] = options[:timeout].to_i unless Helpers.blank?(options[:timeout])
          builder.request :url_encoded
          builder.adapter adapter
        end
      end

      def make_the_call(http_verb, resource_path, params, body, options)
        connection, request_options, options = strip_options(options)

        remote_call = begin
          set_basic_authentication(connection, options)

          response = connection.send(http_verb, resource_path) do |request|
            request_configuration(request, request_options, options, params, body)
          end

          RemoteCall::Faraday.new(response)
        rescue ::Faraday::Error::ConnectionFailed
          RemoteCall::Errors::ConnectionFailed.new(response)
        rescue ::Faraday::Error::TimeoutError
          RemoteCall::Errors::Timeout.new(response)
        end

        block_given? ? yield(remote_call) : remote_call
      end


      protected ################ PROTECTED ################

      def strip_options(options)
        request_options = options.delete(:request_options) || {}
        
        connection = options.delete(:connection) || generate_connection(nil, options)

        [connection, request_options, options]
      end

      def set_basic_authentication(connection, options)
        connection.basic_auth(options[:endpoint_user], options[:endpoint_pass]) if Helpers.present?(options[:endpoint_user])
      end

      def request_configuration(request, request_options, options, params, body)
        request_options.each { |key, value| request.options.send("#{key}=", value) }
        
        options[:headers].each { |key, value| request.headers[key] = value }
        
        params.each { |key, value| request.params[key] = value }

        request.body = body
      end

    end

  end
end
