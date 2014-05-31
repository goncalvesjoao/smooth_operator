require 'smooth_operator/array_with_meta_data'

module SmoothOperator
  module FinderMethods

    def find(relative_path, data = {}, options = {})
      relative_path = '' if relative_path == :all

      get(relative_path, data, options) do |remote_call|
        if remote_call.ok?
          remote_call.object = HelperMethods
            .build_object(self, remote_call.parsed_response, options)
        end

        block_given? ? yield(remote_call) : remote_call
      end
    end

    module HelperMethods

      extend self

      def build_object(object, parsed_response, options, from_array = false)
        if parsed_response.is_a?(Array)
          parse_array(parsed_response, object, options)
        elsif parsed_response.is_a?(Hash)
          parse_hash(object, parsed_response, options, from_array)
        else
          parsed_response
        end
      end

      def parse_array(parsed_response, object, options)
        parsed_response.map do |array_entry|
          build_object(object, array_entry, options, true)
        end
      end

      def parse_hash(object, parsed_response, options, from_array)
        object_class ||= object.class == Class ? object : object.class

        if parsed_response.include?(object_class.resources_name) && !from_array
          ArrayWithMetaData.new(parsed_response.dup, object_class)
        else
          object_class.new(parsed_response, data_from_server: true)
        end
      end

    end

  end
end
