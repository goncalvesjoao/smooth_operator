require 'faraday'
# require 'typhoeus'
# require 'faraday_middleware'
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
      Faraday.new(url: endpoint) do |builder|
        builder.options.params_encoder = Faraday::NestedParamsEncoder # to properly encode arrays
        builder.options.timeout = timeout unless timeout == ''
        builder.request :url_encoded
        builder.adapter adapter
      end
    end


    protected ################ PROTECTED ################

    def make_the_call(http_verb, relative_path = '', data = {}, options = {})
      params, body = strip_params(http_verb, data)

      connection, connection_options, options = strip_options(options)

      relative_path = build_relative_path(relative_path, options)

      begin
        set_basic_authentication(connection, options)

        response = connection.send(http_verb) do |request|
          connection_options.each { |key, value| request.options.send("#{key}=", value) }
          params.each { |key, value| request.params[key] = value }
          
          request.url relative_path
          request.body = body
        end

        RemoteCall::Base.new(response)
      rescue Faraday::ConnectionFailed
        RemoteCall::ConnectionFailed.new
      end
    end

    def query_string(options)
      options
    end


    private ################# PRIVATE ###################

    def build_relative_path(relative_path, options)
      table_name = options[:table_name] || self.table_name

      if Helpers.present?(table_name)
        Helpers.present?(relative_path) ? "#{table_name}/#{relative_path}" : table_name
      else
        relative_path
      end
    end

    def strip_params(http_verb, data)
      data ||= {}

      ([:get, :head, :delete].include?(http_verb) ? [query_string(data), nil] : [query_string({}), data])
    end

    def strip_options(options)
      options ||= {}

      connection_array, connection_options = options.delete(:connection), {}

      if connection_array.is_a?(Array)
        connection, connection_options = *connection_array
      else
        connection = connection_array || generate_connection
      end

      [connection, connection_options, options]
    end

    def set_basic_authentication(connection, options)
      endpoint_user = options[:endpoint_user] || self.endpoint_user
      endpoint_pass = options[:endpoint_pass] || self.endpoint_pass

      connection.basic_auth(endpoint_user, endpoint_pass) if Helpers.present?(endpoint_user)
    end

  end

end
