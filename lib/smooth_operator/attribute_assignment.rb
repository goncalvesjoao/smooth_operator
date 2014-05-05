require 'smooth_operator/attributes/base'
require 'smooth_operator/attributes/dirty'

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


    def initialize(attributes = {})
      before_initialize(attributes)

      assign_attributes attributes

      after_initialize(attributes)
    end

    def assign_attributes(attributes = {})
      return nil unless attributes.is_a?(Hash)
      
      attributes.each { |name, value| push_to_internal_data(name, value) }
    end

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

    def before_initialize(attributes); end

    def after_initialize(attributes); end

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
        internal_data[attribute_name].set_value(attribute_value)
      else
        internal_data[attribute_name] = new_attribute_object(attribute_name, attribute_value)
      end
    end

    def new_attribute_object(attribute_name, attribute_value)
      attribute_class = self.class.dirty_attributes? ?  Attributes::Dirty : Attributes::Base
      
      attribute_class.new(attribute_name, attribute_value, internal_structure[attribute_name], self.class.unknown_hash_class)
    end

  end

end
