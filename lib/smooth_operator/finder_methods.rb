require 'smooth_operator/array_with_meta_data'

module SmoothOperator
  
  module FinderMethods

    def all(data = {}, options = {})
      find(:all, data, options)
    end

    def find(relative_path, data = {}, options = {})
      relative_path = '' if relative_path == :all

      returning_object = {}

      get(relative_path, data, options).tap do |remote_call|
        remote_call.object = build_object(remote_call.parsed_response, options) if remote_call.success?

        returning_object = remote_call
      end

      returning_object
    end


    protected #################### PROTECTED ##################

    def build_object(parsed_response, options)
      options ||={}
      
      table_name = (options[:table_name] || self.table_name).to_s

      if parsed_response.is_a?(Array)
        parsed_response.map { |array_entry| build_object(array_entry, options) }
      elsif parsed_response.is_a?(Hash)
        parsed_response.include?(table_name) ? ArrayWithMetaData.new(parsed_response, table_name, self) : new(parsed_response).tap { |object| object.reloaded = true }
      else
        parsed_response
      end
    end

  end
  
end
