require 'smooth_operator/array_with_meta_data'

module SmoothOperator
  
  module FinderMethods

    def all(data = {}, options = {})
      find(:all, data, options)
    end

    def find(relative_path, data = {}, options = {})
      relative_path = '' if relative_path == :all

      get(relative_path, data, options) do |remote_call|
        remote_call.object = build_object(remote_call.parsed_response, options) if remote_call.ok?

        block_given? ? yield(remote_call) : remote_call
      end
    end


    protected #################### PROTECTED ##################

    def build_object(parsed_response, options, from_array = false)
      options ||={}

      if parsed_response.is_a?(Array)
        parsed_response.map { |array_entry| build_object(array_entry, options, true) }
      elsif parsed_response.is_a?(Hash)
        if !from_array && parsed_response.include?(resources_name)
          ArrayWithMetaData.new(parsed_response, self)
        else
          new(parsed_response, from_server: true)
        end
      else
        parsed_response
      end
    end

  end
  
end
