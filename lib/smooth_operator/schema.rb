module SmoothOperator
  module Schema

    def known_by_schema?(attribute)
      self.class.internal_structure.include?(attribute.to_s)
    end

    def get_attribute_type(attribute)
      self.class.internal_structure[attribute.to_s]
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      attr_writer :resource_name

      def schema(structure)
        internal_structure.merge! Helpers.stringify_keys(structure)

        known_attributes.merge internal_structure.keys
      end

      def internal_structure
        Helpers.get_instance_variable(self, :internal_structure, { "errors" => nil, primary_key => nil, destroy_key => nil })
      end

    end

  end
end
