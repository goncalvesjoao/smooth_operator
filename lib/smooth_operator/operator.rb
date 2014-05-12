require "smooth_operator/remote_call/base"
require "smooth_operator/operators/faraday"
require "smooth_operator/operators/typhoeus"
require "smooth_operator/remote_call/errors/timeout"
require "smooth_operator/remote_call/errors/connection_failed"

module SmoothOperator

  module Operator

    OPTIONS = [:endpoint, :endpoint_user, :endpoint_pass, :timeout]

    OPTIONS.each do |option|
      define_method(option) { Helpers.get_instance_variable(self, option, '') }
    end

    attr_writer *OPTIONS
    
    %w[get post put patch delete].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(relative_path = '', params = {}, options = {})
          make_the_call(:#{method}, relative_path, params, options) do |remote_call|
            block_given? ? yield(remote_call) : remote_call
          end
        end
      RUBY
    end


    def headers
      Helpers.get_instance_variable(self, :headers, {})
    end

    attr_writer :headers


    def make_the_call(http_verb, relative_path = '', data = {}, options = {})
      operator_args = operator_method_args(http_verb, relative_path, data, options)

      if Helpers.present?(operator_args[4][:hydra])
        operator_call = Operators::Typhoeus
      else
        operator_call = Operators::Faraday
      end
      
      operator_call.make_the_call(*operator_args) do |remote_call|
        block_given? ? yield(remote_call) : remote_call
      end
    end

    def query_string(params)
      params
    end


    protected #################### PROTECTED ##################

    def operator_method_args(http_verb, relative_path, data, options)
      options = populate_options(options)

      [http_verb, resource_path(relative_path, options), *strip_params(http_verb, data), options]
    end


    private #################### PRIVATE ##################

    def populate_options(options)
      options ||= {}

      OPTIONS.each { |option| options[option] ||= send(option) }

      options[:headers] = headers.merge(options[:headers] || {})
      
      options
    end

    def resource_path(relative_path, options)
      table_name = options[:table_name] || self.table_name

      if Helpers.present?(table_name)
        Helpers.present?(relative_path) ? "#{table_name}/#{relative_path}" : table_name
      else
        relative_path.to_s
      end
    end

    def strip_params(http_verb, data)
      data ||= {}
      
      if [:get, :head, :delete].include?(http_verb)
        [query_string(data), nil]
      else
        [query_string({}), data]
      end
    end

  end

end
