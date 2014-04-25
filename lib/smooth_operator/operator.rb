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

    def generate_connection(adapter = nil, options = nil)
      adapter ||= :net_http
      options ||= {}
      url, timeout = (options[:endpoint] || self.endpoint), (options[:timeout] || self.timeout)

      Faraday.new(url: url) do |builder|
        builder.options.params_encoder = Faraday::NestedParamsEncoder # to properly encode arrays
        builder.options.timeout = timeout unless Helpers.blank?(timeout)
        builder.request :url_encoded
        builder.adapter adapter
      end
    end


    protected ################ PROTECTED ################
    #COMPLEX
    def make_the_call(http_verb, relative_path = '', data = {}, options = {})
      params, body = strip_params(http_verb, data)

      connection, operator_options, options = strip_options(options)

      relative_path = build_relative_path(relative_path, options)

      begin
        set_basic_authentication(connection, operator_options)

        response = connection.send(http_verb) do |request|
          operator_options.each { |key, value| request.options.send("#{key}=", value) }
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

      operator_options = options.delete(:operator_options) || {}
      connection = options.delete(:connection) || generate_connection(nil, operator_options)

      [connection, operator_options, options]
    end

    def set_basic_authentication(connection, options)
      endpoint_user = options[:endpoint_user] || self.endpoint_user
      endpoint_pass = options[:endpoint_pass] || self.endpoint_pass

      connection.basic_auth(endpoint_user, endpoint_pass) if Helpers.present?(endpoint_user)
    end

  end

end
