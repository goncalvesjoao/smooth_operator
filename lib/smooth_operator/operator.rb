require "smooth_operator/operators/base"
require "smooth_operator/remote_call/base"
require "smooth_operator/operators/faraday"
require "smooth_operator/operators/typhoeus"
require "smooth_operator/remote_call/errors/timeout"
require "smooth_operator/remote_call/errors/connection_failed"

module SmoothOperator

  module Operator

    HTTP_VERBS = [:get, :post, :put, :patch, :delete]

    OPTIONS = [:endpoint, :endpoint_user, :endpoint_pass, :timeout]


    attr_writer *OPTIONS

    OPTIONS.each { |option| define_method(option) { Helpers.get_instance_variable(self, option, '') } }

    HTTP_VERBS.each { |http_verb| define_method(http_verb) { |relative_path = '', params = {}, options = {}| make_the_call(http_verb, relative_path, params, options) } }

    def headers
      Helpers.get_instance_variable(self, :headers, {})
    end

    attr_writer :headers

    
    def generate_parallel_connection
      generate_connection(:typhoeus)
    end

    def generate_connection(adapter = nil, options = nil)
      adapter ||= :net_http
      options ||= {}
      url, timeout = (options[:endpoint] || self.endpoint), (options[:timeout] || self.timeout)

      ::Faraday.new(url: url) do |builder|
        builder.options[:timeout] = timeout unless Helpers.blank?(timeout)
        builder.request :url_encoded
        builder.adapter adapter
      end
    end

    def make_the_call(http_verb, relative_path = '', data = {}, options = {})
      if Helpers.present?(options[:hydra])
        operator_call = Operators::Typhoeus.new(self, http_verb, relative_path, data, options)
      else
        operator_call = Operators::Faraday.new(self, http_verb, relative_path, data, options)
      end

      remote_call = {}

      operator_call.make_the_call do |_remote_call|
        remote_call = _remote_call

        yield(remote_call) if block_given?
      end

      remote_call
    end


    protected ################ PROTECTED ################

    def query_string(params)
      params
    end

  end

end
