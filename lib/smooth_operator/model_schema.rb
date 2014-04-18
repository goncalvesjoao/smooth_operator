module SmoothOperator

  module ModelSchema

    def self.included(base)
      base.extend(ClassMethods)
    end

    def known_attributes
      @known_attributes ||= self.class.known_attributes
    end

    def internal_structure
      @internal_structure ||= self.class.internal_structure
    end

    
    module ClassMethods

      attr_accessor :table_name

      def schema(structure)
        internal_structure.merge! Helpers.stringify_keys(structure)

        known_attributes.merge internal_structure.keys
      end

      def internal_structure
        @internal_structure ||= (zuper_method(:internal_structure) || {}).dup
      end

      def known_attributes
        @known_attributes ||= (zuper_method(:known_attributes) || Set.new).dup
      end

    end

  end

end
