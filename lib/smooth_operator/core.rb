module SmoothOperator
  module Core

    def table_hash
      @table
    end

    def as_json(options = nil)
      @table.as_json(options)
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

    private ######################### PRIVATE ###############################

    def get_nested_object_variable(nested_object_symbol, nested_object_class_or_options)
      nested_object_variable = instance_variable_get("@#{nested_object_symbol}")

      return nested_object_variable if nested_object_variable.present?

      nested_object_variable = initialize_nested_object_variable(table_hash[nested_object_symbol], nested_object_class_or_options, nested_object_symbol)

      instance_variable_set("@#{nested_object_symbol}", nested_object_variable)

      nested_object_variable
    end

    def initialize_nested_object_variable(attributes, nested_object_class_or_options, nested_object_symbol)
      if attributes.kind_of?(Array)
        get_nested_objects(attributes, nested_object_class_or_options, nested_object_symbol)
      else
        get_nested_object(attributes, nested_object_class_or_options, nested_object_symbol)
      end
    end

    def get_nested_objects(nested_objects_attributes, nested_object_class_or_options, nested_object_symbol)
      nested_objects = nested_objects_attributes.map { |attributes| get_nested_object(attributes, nested_object_class_or_options, nested_object_symbol) }

      if nested_object_class_or_options.kind_of?(Hash)
        nested_objects = order_by(nested_objects, nested_object_class_or_options[:order_by], nested_object_class_or_options[:order])
      end

      nested_objects
    end

    def get_nested_object(nested_objects_attributes, nested_object_class_or_options, nested_object_symbol)
      return (plural?(nested_object_symbol) ? [] : nil) if nested_objects_attributes.blank?
      
      return get_nested_object_according_to_options(nested_objects_attributes, nested_object_class_or_options, nested_object_symbol) if nested_object_class_or_options.kind_of?(Hash)

      nested_object_class_or_options.new(nested_objects_attributes)
    end

    def get_nested_object_according_to_options(nested_objects_attributes, options, nested_object_symbol)
      nested_objects_attributes = options[:parser].call(nested_objects_attributes) if options[:parser].present?

      begin
        options[:class].new(nested_objects_attributes)
      rescue
        options[:default].present? ? options[:default] : nested_objects_attributes
      end
    end

    def plural?(string)
      string = string.to_s
      string == string.pluralize
    end

    def order_by(list, method, order)
      return list if method.blank? || order.blank?

      if order == :asc
        list.sort { |a, b| a.send(method) <=> b.send(method) }
      elsif order == :desc
        list.sort { |a, b| b.send(method) <=> a.send(method) }
      end
    end


    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      
      def nested_objects_classes(hash)
        hash.each do |nested_object_symbol, nested_object_class_or_options|
          define_method(nested_object_symbol.to_s) do
            get_nested_object_variable(nested_object_symbol, nested_object_class_or_options)
          end
        end
      end

      attr_writer :endpoint
      def endpoint
        if defined?(@endpoint)
          @endpoint
        else
          @endpoint = superclass_responds_to?(:endpoint) ? superclass.endpoint : ENV["API_ENDPOINT"]
        end
      end

      attr_writer :endpoint_user
      def endpoint_user
        if defined?(@endpoint_user)
          @endpoint_user
        else
          @endpoint_user = superclass_responds_to?(:endpoint_user) ? superclass.endpoint_user : ENV["API_USER"]
        end
      end

      attr_writer :endpoint_pass
      def endpoint_pass
        if defined?(@endpoint_pass)
          @endpoint_pass
        else
          @endpoint_pass = superclass_responds_to?(:endpoint_pass) ? superclass.endpoint_pass : ENV["API_PASS"]
        end
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

      def human_attribute_name(attribute_key_name, options = {})
        defaults = []
        defaults << "smooth_operator.attributes.#{name.underscore}.#{attribute_key_name}"
        defaults << "activerecord.attributes.#{name.underscore}.#{attribute_key_name}".to_sym
        defaults << options[:default] if options[:default]
        defaults.flatten!
        defaults << attribute_key_name.to_s.humanize
        options[:count] ||= 1
        I18n.translate(defaults.shift, options.merge(default: defaults))
      end

      private ################################ PRIVATE #########################

      def superclass_responds_to?(method_name)
        superclass.name.split('::')[0] != 'SmoothOperator' && superclass.respond_to?(method_name)
      end

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
