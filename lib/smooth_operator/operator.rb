require 'faraday'
# require 'faraday_middleware'
# require 'typhoeus'
# require 'typhoeus/adapters/faraday'

module SmoothOperator

  module Operator

    HTTP_VERBS = [:get, :post, :put, :patch, :delete]

    OPTIONS = [:endpoint, :endpoint_user, :endpoint_pass, :timeout]


    attr_writer *OPTIONS

    OPTIONS.each { |option| define_method(option) { Helpers.get_instance_variable(self, option, '') } }

    HTTP_VERBS.each { |http_verb| define_method(http_verb) { |relative_path = '', params = {}, options = {}| make_the_call(http_verb, relative_path, params, options) } }


    def generate_parallel_connection
      generate_connection(:typhoeus)
    end

    def generate_connection(adapter = :net_http)
      Faraday.new(url: endpoint) do |faraday|
        faraday.request :url_encoded
        faraday.adapter adapter
      end
    end


    protected ################ PROTECTED ################

    def make_the_call(http_verb, relative_path = '', data = {}, options = {})
      url = Helpers.present?(table_name) ? "#{table_name}/#{relative_path}" : relative_path

      connection, options = strip_options(options)

      params, body = *([:get, :head, :delete].include?(http_verb) ? [data, nil] : [{}, data])

      begin
        response = connection.send(http_verb) do |request|
          params.each { |key, value| request.params[key] = value }
          options.each { |key, value| request.options.send("#{key}=", value) }

          request.url url
          request.body = body
        end

        RemoteCall::Base.new(response)
      rescue Faraday::ConnectionFailed
        RemoteCall::ConnectionFailed.new
      end
    end


    private ################# PRIVATE ###################

    def strip_options(options)
      options ||= { params_encoder: Faraday::FlatParamsEncoder }

      options[:timeout] ||= timeout unless timeout == ''
      connection = (options.delete(:connection) || generate_connection)

      [connection, options]
    end

  end

end
