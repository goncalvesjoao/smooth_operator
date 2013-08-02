require "smooth_operator/protocol_handler"

module SmoothOperator
  module Operator

    HTTP_SUCCESS_CODES = [200, 201, 202, 203, 204]

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

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
        make_the_call(:get, relative_path, SmoothOperator::ProtocolHandler.get_options(options))
      end

      def post(relative_path, options = {})
        make_the_call(:post, relative_path, SmoothOperator::ProtocolHandler.post_options(options))
      end

      def put(relative_path, options = {})
        make_the_call(:put, relative_path, SmoothOperator::ProtocolHandler.put_options(options))
      end

      def delete(relative_path, options = {})
        make_the_call(:delete, relative_path, SmoothOperator::ProtocolHandler.delete_options(options))
      end


      def safe_get(relative_path, options = {})
        safe_response(get(relative_path, options)) rescue nil
      end

      def safe_post(relative_path, options = {})
        safe_response(post(relative_path, options)) rescue nil
      end

      def safe_put(relative_path, options = {})
        safe_response(put(relative_path, options)) rescue nil
      end

      def safe_delete(relative_path, options = {})
        safe_response(delete(relative_path, options)) rescue nil
      end

      def safe_response(response)
        successful_response?(response) ? response.parsed_response : nil
      end
      

      def make_the_call(http_verb, relative_path, options = {})
        url = build_url(relative_path)
        options = build_options(options)
        response = SmoothOperator::ProtocolHandler.send(http_verb, url, options)
        response
      end

      def build_url(relative_path)
        slash = '/' if relative_path.present?
        extention = '.json'
        [endpoint, table_name, slash, relative_path.to_s, extention].join
      end

      def set_basic_auth_credentials(options)
        if endpoint_user.present? || endpoint_pass.present? && !options.include?(:basic_auth)
          options.merge({ basic_auth: { username: endpoint_user, password: endpoint_pass } })
        else
          options
        end
      end

      def build_options(options)
        options = {} if options.blank?
        set_basic_auth_credentials(options)
      end

      def successful_response?(response)
        HTTP_SUCCESS_CODES.include?(response.code) || response.blank?
      end

    end

  end
end
