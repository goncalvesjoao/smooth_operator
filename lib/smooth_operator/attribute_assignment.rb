module SmoothOperator

  module AttributeAssignment

    def initialize(attributes = {})
      before_initialize(attributes)

      assign_attributes attributes

      after_initialize(attributes)
    end

    def assign_attributes(attributes = {})
      raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
      
      attributes.each { |name, value| push_to_internal_data(name, value) }
    end

    def internal_data
      @internal_data ||= {}
    end

    def push_to_internal_data(attribute_name, attribute_value)
      attribute_name = attribute_name.to_s

      return nil unless allowed_attribute(attribute_name)
      
      internal_data[attribute_name] = parse_attribute(attribute_name, attribute_value)
    end


    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def before_initialize(attributes); end

    def after_initialize(attributes); end

    def allowed_attribute(attribute)
      true
    end

    def parse_attribute(name, value)
      case value
      when Array
        resource = nil
        value.map do |attributes|
          if attributes.is_a?(Hash)
            resource ||= find_or_create_resource_for(name)
            resource.new(attributes)
          else
            Helpers.duplicate(attributes)
          end
        end
      when Hash
        resource = find_or_create_resource_for(name)
        resource.new(value)
      else
        Helpers.duplicate(value)
      end
    end

    # TODO: THE RESOURCE SHOULD BE COMING FROM SOME SORT OF SCHEMA
    def find_or_create_resource_for(attribute_symbol)
      OpenStruct
    end

  end

end
