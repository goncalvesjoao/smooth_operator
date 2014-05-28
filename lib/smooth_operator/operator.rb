require "smooth_operator/remote_call/base"
require "smooth_operator/operators/faraday"
require "smooth_operator/operators/typhoeus"
require "smooth_operator/remote_call/errors/timeout"
require "smooth_operator/remote_call/errors/connection_failed"

module SmoothOperator

  module Operator

    def make_the_call(http_verb, relative_path = '', data = {}, options = {})
      options ||= {}
      
      relative_path = resource_path(relative_path)
      
      if !parent_object.nil? && options[:ignore_parent] != true
        options[:resources_name] ||= "#{parent_object.class.resources_name}/#{parent_object.get_primary_key}/#{self.class.resources_name}"
      end
      
      self.class.make_the_call(http_verb, relative_path, data, options) do |remote_call|
        yield(remote_call)
      end
    end

    protected ######################## PROTECTED ###################

    def resource_path(relative_path)
      if Helpers.absolute_path?(relative_path)
        Helpers.remove_initial_slash(relative_path)
      elsif persisted?
        Helpers.present?(relative_path) ? "#{get_primary_key}/#{relative_path}" : get_primary_key.to_s
      else
        relative_path
      end
    end


    ########################### MODULES BELLOW ###############################

    module HttpMethods

      HTTP_VERBS = %w[get post put patch delete]
      
      HTTP_VERBS.each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}(relative_path = '', params = {}, options = {})
            make_the_call(:#{method}, relative_path, params, options) do |remote_call|
              block_given? ? yield(remote_call) : remote_call
            end
          end
        RUBY
      end

    end

    module ClassMethods

      OPTIONS = [:endpoint, :endpoint_user, :endpoint_pass, :timeout]

      OPTIONS.each do |option|
        define_method(option) { Helpers.get_instance_variable(self, option, '') }
      end

      attr_writer *OPTIONS

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
        _resources_name = options[:resources_name] || self.resources_name

        if Helpers.present?(_resources_name)
          Helpers.present?(relative_path) ? "#{_resources_name}/#{relative_path}" : _resources_name
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

    
    include HttpMethods

    def self.included(base)
      base.extend(ClassMethods)
      base.extend(HttpMethods)
    end

  end

end
