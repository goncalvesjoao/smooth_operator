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

      attr_accessor :table_name

      def schema(structure)
        internal_structure.merge! Helpers.stringify_keys(structure)

        known_attributes.merge internal_structure.keys
      end

      def internal_structure
        @internal_structure ||= (Helpers.super_method(self, :internal_structure) || {}).dup
      end

      def known_attributes
        @known_attributes ||= (Helpers.super_method(self, :known_attributes) || Set.new).dup
      end

    end

  end

end
