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
      
      known_attributes.add attribute_name
      
      internal_data[attribute_name] = cast_according_to_schema(attribute_name, attribute_value)
    end


    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def before_initialize(attributes); end

    def after_initialize(attributes); end

    def allowed_attribute(attribute)
      true
    end

    def cast_according_to_schema(attribute_name, attribute_value)
      case attribute_value
      when Array
        attribute_value.map { |array_entry| cast_according_to_schema(attribute_name, array_entry) }
      when Hash
        class_according_to_schema(attribute_name).new(attribute_value)
      else
        field_according_to_schema(attribute_name, Helpers.duplicate(attribute_value))
      end
    end

    def class_according_to_schema(attribute_name)
      internal_structure[attribute_name] || OpenStruct
    end

    def field_according_to_schema(attribute_name, attribute_value)
      case internal_structure[attribute_name]

      when [:float]
        attribute_value.to_f

      when [:bool, :boolean]
        ['1', 'true', true].include?(attribute_value.dowcase) ? true : ['0', 'false', false].include?(attribute_value.dowcase) ? false : nil

      when [:date, Date]
        attribute_value.to_date rescue nil

      when [:string, String]
        attribute_value.to_s

      when [:int, :integer, Integer]
        attribute_value.to_i

      else
        attribute_value
      end
    end

  end

end
