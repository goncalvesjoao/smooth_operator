require 'smooth_operator/internal_attribute'

module SmoothOperator

  module AttributeAssignment

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      attr_accessor :turn_unknown_hash_to_open_struct

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
      internal_data[field].nil? ? nil : internal_data[field].send(method)
    end

    def push_to_internal_data(attribute_name, attribute_value)
      attribute_name = attribute_name.to_s

      return nil unless allowed_attribute(attribute_name)
      
      known_attributes.add attribute_name
      
      if internal_data[attribute_name].nil?
        internal_data[attribute_name] = InternalAttribute.new(attribute_name, attribute_value, internal_structure[attribute_name], self.class.turn_unknown_hash_to_open_struct)
      else
        internal_data[attribute_name].set_value(attribute_value)
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

  end

end
