module SmoothOperator

  module Operators

    class Base

      attr_reader :operator_class, :http_verb, :params, :body, :connection, :operator_options, :options, :relative_path, :endpoint_user, :endpoint_pass

      def initialize(operator_class, http_verb, relative_path, data, options)
        @operator_class, @http_verb = operator_class, http_verb

        @params, @body = strip_params(http_verb, data)

        @connection, @operator_options, @options = strip_options(options)

        @relative_path = build_relative_path(relative_path, options)

        @endpoint_user = options[:endpoint_user] || @operator_class.endpoint_user
        
        @endpoint_pass = options[:endpoint_pass] || @operator_class.endpoint_pass
      end


      protected ################# PROTECTED ###################

      def strip_params(http_verb, data)
        data ||= {}
        
        ([:get, :head, :delete].include?(http_verb) ? [@operator_class.query_string(data), nil] : [@operator_class.query_string({}), data])
      end

      def strip_options(options)
        options ||= {}

        options[:headers] = @operator_class.headers.merge(options[:headers] || {})
        operator_options = options.delete(:operator_options) || {}
        connection = options.delete(:connection) || @operator_class.generate_connection(nil, operator_options)

        [connection, operator_options, options]
      end

      def build_relative_path(relative_path, options)
        table_name = options[:table_name] || @operator_class.table_name

        if Helpers.present?(table_name)
          Helpers.present?(relative_path) ? "#{table_name}/#{relative_path}" : table_name
        else
          relative_path
        end
      end
    
    end

  end
end
