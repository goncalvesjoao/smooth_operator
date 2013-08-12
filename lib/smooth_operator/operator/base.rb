module SmoothOperator
  module Operator

    module Base

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

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
          http_handler_base.make_the_call(http_verb, url, (options || {}), get_basic_auth_credentials)
        end

      end

    end

  end
end
