module SmoothOperator
  module Schema

    def schema(structure)
      internal_structure.merge! Helpers.stringify_keys(structure)
    end

    def internal_structure
      Helpers.get_instance_variable(self, :internal_structure, {})
    end

    def known_attribute?(attribute)
      internal_structure.has_key?(attribute.to_s)
    end

    def attribute_type(attribute)
      internal_structure[attribute.to_s]
    end

  end
end
