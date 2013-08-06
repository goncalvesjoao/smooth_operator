module SmoothOperator
  module Operator

    def self.included(base)
      base.extend(ClassMethods)
    end

    def http_handler_base
      @http_handler_base ||= SmoothOperator::ProtocolHandlers::http_handler::ORM.new(self, self.class)
    end

    module ClassMethods

      attr_writer :http_handler
      def http_handler
        @http_handler ||= HTTParty
      end

      def http_handler_base
        @http_handler_base ||= SmoothOperator::ProtocolHandlers::http_handler::Base
      end

      attr_writer :endpoint
      def endpoint
        @endpoint ||= ENV["API_ENDPOINT"]
      end

      attr_writer :endpoint_user
      def endpoint_user
        @endpoint_user ||= ENV["API_USER"]
      end

      attr_writer :endpoint_pass
      def endpoint_pass
        @endpoint_pass ||= ENV["API_PASS"]
      end

      def get(relative_path, options = {})
        make_the_call(:get, relative_path, options)
      end

      def post(relative_path, options = {})
        make_the_call(:post, relative_path, options)
      end

      def put(relative_path, options = {})
        make_the_call(:put, relative_path, options)
      end

      def delete(relative_path, options = {})
        make_the_call(:delete, relative_path, options)
      end

      def make_the_call(http_verb, relative_path, options = {})
        url = build_url(relative_path)
        http_handler_base.send(http_verb, url, (options || {}), get_basic_auth_credentials)
      end

      private ################################ PRIVATE #########################

      def build_url(relative_path)
        slash = '/' if relative_path.present?
        extention = '.json'
        [endpoint, table_name, slash, relative_path.to_s, extention].join
      end

      def get_basic_auth_credentials
        if endpoint_user.present? || endpoint_pass.present?
          { username: endpoint_user, password: endpoint_pass }
        else
          nil
        end
      end

    end

  end
end
