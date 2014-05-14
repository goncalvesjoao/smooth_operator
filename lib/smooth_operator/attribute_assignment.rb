require 'smooth_operator/attributes/base'
require 'smooth_operator/attributes/dirty'
require 'smooth_operator/attributes/normal'

module SmoothOperator

  module AttributeAssignment

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      attr_writer :unknown_hash_class

      def unknown_hash_class
        Helpers.get_instance_variable(self, :unknown_hash_class, ::OpenStruct)
      end

      def attributes_white_list
        Helpers.get_instance_variable(self, :attributes_white_list, Set.new)
      end

      def attributes_black_list
        Helpers.get_instance_variable(self, :attributes_black_list, Set.new)
      end

      def attributes_white_list_add(*getters)
        attributes_white_list.merge getters.map(&:to_s)
      end

      def attributes_black_list_add(*getters)
        attributes_black_list.merge getters.map(&:to_s)
      end

      def dirty_attributes
        @dirty_attributes = true
      end

      def dirty_attributes?
        @dirty_attributes
      end

    end


    def initialize(attributes = {}, options = {})
      @_options = {}

      before_initialize(attributes, options)

      assign_attributes attributes, options

      after_initialize(attributes, options)
    end

    attr_reader :_options, :_meta_data


    def assign_attributes(_attributes = {}, options = {})
      return nil unless _attributes.is_a?(Hash)
      
      attributes = _attributes = Helpers.stringify_keys(_attributes)

      if _attributes.include?(resource_name)
        attributes = _attributes.delete(resource_name)
        @_meta_data = _attributes
      end
      
      options.each { |key, value| @_options[key] = value } if options.is_a?(Hash)

      attributes.each { |name, value| push_to_internal_data(name, value) }
    end

    def parent_object
      _options[:parent_object]
    end

    def has_data_from_server
      _options[:from_server] == true
    end

    alias :from_server :has_data_from_server

    def internal_data
      @internal_data ||= {}
    end

    def get_internal_data(field, method = :value)
      result = internal_data[field]

      if result.nil?
        nil
      elsif method == :value
        result.is_a?(Attributes::Dirty) ? internal_data[field].send(method) : internal_data[field]
      else
        internal_data[field].send(method)
      end
    end

    def push_to_internal_data(attribute_name, attribute_value)
      attribute_name = attribute_name.to_s

      return nil unless allowed_attribute(attribute_name)
      
      known_attributes.add attribute_name
      
      if internal_data[attribute_name].nil?
        initiate_internal_data(attribute_name, attribute_value)
      else
        update_internal_data(attribute_name, attribute_value)
      end
    end

    
    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def before_initialize(attributes, options); end

    def after_initialize(attributes, options); end

    def allowed_attribute(attribute)
      if !self.class.attributes_white_list.empty?
        self.class.attributes_white_list.include?(attribute)
      elsif !self.class.attributes_black_list.empty?
        !self.class.attributes_black_list.include?(attribute)
      else
        true
      end
    end


    private ######################## PRIVATE #############################

    def initiate_internal_data(attribute_name, attribute_value)
      internal_data[attribute_name] = new_attribute_object(attribute_name, attribute_value)
      
      internal_data[attribute_name] = internal_data[attribute_name].value unless self.class.dirty_attributes?
    end

    def update_internal_data(attribute_name, attribute_value)
      if self.class.dirty_attributes?
        internal_data[attribute_name].set_value(attribute_value, self)
      else
        internal_data[attribute_name] = new_attribute_object(attribute_name, attribute_value).value
      end
    end

    def new_attribute_object(attribute_name, attribute_value)
      attribute_class = self.class.dirty_attributes? ?  Attributes::Dirty : Attributes::Normal
      
      attribute_class.new(attribute_name, attribute_value, self)
    end

  end

end
