module SmoothOperator
  module Core

    def table_hash
      @table
    end

    def as_json(options = nil)
      @table.as_json(options)
    end

    # def self.nested_objects_classes(hash)
    #   hash.each do |nested_object_symbol, nested_object_class|
    #     define_method(nested_object_symbol.to_s) do
    #       get_nested_object_variable(nested_object_symbol, nested_object_class)
    #     end
    #   end
    # end

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


    private ######################### PRIVATE ###############################

    def get_nested_object_variable(nested_object_symbol, nested_object_class)
      nested_object_variable = instance_variable_get("@#{nested_object_symbol}")

      return nested_object_variable if nested_object_variable.present?

      nested_object_variable = initialize_nested_object_variable(table_hash[nested_object_symbol], nested_object_class, nested_object_symbol)

      instance_variable_set("@#{nested_object_symbol}", nested_object_variable)

      nested_object_variable
    end

    def initialize_nested_object_variable(attributes, nested_object_class, nested_object_symbol)
      if attributes.kind_of? Array
        attributes.map { |_attributes| get_nested_object(_attributes, nested_object_class, nested_object_symbol) }
      else
        get_nested_object(attributes, nested_object_class, nested_object_symbol)
      end
    end

    def get_nested_object(nested_objects_attributes, nested_object_class, nested_object_symbol)
      if nested_objects_attributes.blank?
        plural?(nested_object_symbol) ? [] : nil
      else
        nested_object_class.new(nested_objects_attributes)
      end
    end

    def plural?(string)
      string = string.to_s
      string == string.pluralize
    end


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

      attr_writer :save_attr_black_list
      def save_attr_black_list
        @save_attr_black_list ||= [:id, :created_at, :updated_at, :errors]
      end

      attr_writer :save_attr_white_list
      def save_attr_white_list
        @save_attr_white_list ||= []
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
