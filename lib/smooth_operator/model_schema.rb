module SmoothOperator

  module ModelSchema

    def self.included(base)
      base.extend(ClassMethods)
    end

    def known_attributes
      @known_attributes ||= self.class.known_attributes.dup
    end

    def internal_structure
      @internal_structure ||= self.class.internal_structure.dup
    end

    
    module ClassMethods

      attr_writer :table_name

      def table_name
        @table_name ||= self.model_name.to_s.downcase.pluralize
      end

      def schema(structure)
        internal_structure.merge! Helpers.stringify_keys(structure)

        known_attributes.merge internal_structure.keys
      end

      def internal_structure
        Helpers.get_instance_variable(self, :internal_structure, {})
      end

      def known_attributes
        Helpers.get_instance_variable(self, :known_attributes, Set.new)
      end

    end

  end

end
