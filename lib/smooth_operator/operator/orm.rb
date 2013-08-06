module SmoothOperator
  module ORM

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:attr_reader, :last_response)
    end

    module ClassMethods

      attr_writer :save_attr_black_list
      def save_attr_black_list
        @save_attr_black_list ||= [:id, :created_at, :updated_at]
      end

      attr_writer :save_attr_white_list
      def save_attr_white_list
        @save_attr_white_list ||= []
      end

      def find(id, options = {})
        if id == :all
          find_each(options)
        else
          find_one(id, options)
        end
      end

      def safe_find(id, options = {})
        begin
          find(id, options)
        rescue Exception => exception #exception.response contains the server response
          id == :all ? [] : nil
        end
      end

      attr_writer :model_name
      def model_name
        @model_name ||= name.split('::').last.underscore.capitalize
      end

      def model_name_downcase
        model_name.downcase
      end

      attr_writer :table_name
      def table_name
        @table_name ||= model_name_downcase.to_s.pluralize
      end

      private #------------------------------------------------ private

      def find_each(options)
        http_handler_orm.find_each(options) do |remote_call|
          remote_call.response = return_array_of_objects_or_response(remote_call.parsed_response)
        end
      end

      def find_one(id, options)
        http_handler_orm.find_one(id, options) do |remote_call|
          remote_call.response = new(remote_call.parsed_response)
        end
      end

      def return_array_of_objects_or_response(parsed_response)
        if parsed_response.kind_of?(Array)
          parsed_response.map { |attributes| new(attributes) }
        else
          parsed_response
        end
      end

    end

    def save(options = {})
      begin
        save!(options)
      rescue Exception => exception
        false
      end
    end

    def save!(options = {})
      if new_record?
        http_handler_orm.create(options) { |remote_call| after_create_update_or_destroy(remote_call) }
      else
        http_handler_orm.update(id, options) { |remote_call| after_create_update_or_destroy(remote_call) }
      end
    end

    def destroy(options = {})
      return true if new_record?
      
      http_handler_orm.destroy(id, options) do |remote_call|
        after_create_update_or_destroy(remote_call)
      end
    end

    def after_create_update_or_destroy(remote_call)
      send("last_response=", remote_call.raw_response)

      assign_attributes(remote_call.parsed_response)

      # if !remote_call.successful_response?
      #   SmoothOperator::Exceptions.raise_proper_exception(remote_call.raw_response, remote_call.raw_response.code)
      # end
      remote_call.response = remote_call.successful_response?
    end

    def new_record?
      !persisted?
    end

    def persisted?
      try(:id).present?
    end

    def to_partial_path
      class_name_plural = self.class.table_name
      "#{class_name_plural}/#{class_name_plural.singularize}"
    end

    def valid?
      errors.blank?
    end

    def invalid?
      !valid?
    end

    def assign_attributes(attributes = {})
      return if attributes.blank?

      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def safe_table_hash
      safe_hash = table_hash.dup

      if self.class.save_attr_white_list.present?
        safe_hash.slice!(*self.class.save_attr_white_list)
      else
        self.class.save_attr_black_list.each { |attribute| safe_hash.delete(attribute) }
      end

      safe_hash
    end

    private ####################### private #################

    def last_response=(response)
      @last_response = response
    end

  end
end
