require 'smooth_operator/array_with_meta_data'

module SmoothOperator
  
  module FinderMethods

    def find(relative_path, data = {}, options = {})
      relative_path = '' if relative_path == :all

      get(relative_path, data, options) do |remote_call|
        remote_call.object = build_object(remote_call.parsed_response, options) if remote_call.ok?

        block_given? ? yield(remote_call) : remote_call
      end
    end


    protected #################### PROTECTED ##################

    def build_object(parsed_response, options, from_array = false)
      if parsed_response.is_a?(Array)
        parsed_response.map { |array_entry| build_object(array_entry, options, true) }
      elsif parsed_response.is_a?(Hash)
        if parsed_response.include?(object_class.resources_name) && !from_array
          ArrayWithMetaData.new(parsed_response, object_class)
        else
          object_class.new(parsed_response, from_server: true)
        end
      else
        parsed_response
      end
    end


    private #################### PRIVATE ##################

    def object_class
      @object_class ||= self.class == Class ? self : self.class
    end

  end
  
end
