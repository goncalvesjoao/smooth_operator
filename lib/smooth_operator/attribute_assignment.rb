require 'date'
require 'smooth_operator/type_converter'
require 'smooth_operator/internal_attribute'

module SmoothOperator

  module AttributeAssignment

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

    def get_internal_data(field)
      internal_data[field].nil? ? nil : internal_data[field].value
    end

    def push_to_internal_data(attribute_name, attribute_value)
      attribute_name = attribute_name.to_s

      return nil unless allowed_attribute(attribute_name)
      
      known_attributes.add attribute_name
      
      if internal_data[attribute_name].nil?
        internal_data[attribute_name] = InternalAttribute.new(attribute_name, attribute_value, internal_structure[attribute_name])
      else
        internal_data[attribute_name].set_value(attribute_value)
      end
    end

    
    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def before_initialize(attributes); end

    def after_initialize(attributes); end

    def allowed_attribute(attribute)
      true
    end

  end

end
