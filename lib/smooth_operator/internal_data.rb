require 'smooth_operator/type_casting'

module SmoothOperator
  module InternalData

    def internal_data
      @internal_data ||= {}
    end

    def known_attributes
      return @known_attributes if defined?(@known_attributes)

      schema_attributes = if self.class.respond_to?(:internal_structure)
        self.class.internal_structure.keys
      else
        []
      end

      @known_attributes = Set.new(schema_attributes)
    end

    def known_attribute?(attribute)
      known_attributes.include?(attribute.to_s)
    end

    def internal_data_get(attribute_name)
      internal_data[attribute_name]
    end

    def internal_data_push(attribute_name, attribute_value)
      attribute_name = attribute_name.to_s

      known_attributes.add attribute_name

      internal_data[attribute_name] = TypeCasting.cast_to_type(attribute_name, attribute_value, self)

      if self.class.respond_to?(:smooth_operator?)
        marked_for_destruction?(attribute_value) if attribute_name == self.class.destroy_key

        new_record?(true) if attribute_name == self.class.primary_key
      end
    end

  end
end
