require 'active_support/core_ext'

module SmoothOperator

  module AttributeAssignment

    def initialize(attributes = {})
      before_initialize(attributes)

      assign_attributes attributes

      after_initialize(attributes)
    end

    def assign_attributes(attributes = {})
      raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
      
      @internal_data ||= {}.with_indifferent_access

      attributes.each { |name, value| @internal_data[name] = parse_attribute(name, value) }
    end


    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def before_initialize(attributes); end

    def after_initialize(attributes); end

    def parse_attribute(name, value)
      case value
      when Array
        resource = nil
        value.map do |attributes|
          if attributes.is_a?(Hash)
            resource ||= find_or_create_resource_for(name)
            resource.new(attributes)
          else
            attributes.duplicable? ? attributes.dup : attributes
          end
        end
      when Hash
        resource = find_or_create_resource_for(name)
        resource.new(value)
      else
        value.duplicable? ? value.dup : value
      end
    end

    def find_or_create_resource_for(attribute_symbol)
      OpenStruct
    end

  end

end
