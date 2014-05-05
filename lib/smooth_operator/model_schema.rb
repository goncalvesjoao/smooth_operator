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

    def table_name
      @table_name ||= self.class.table_name.dup
    end

    def model_name
      @model_name ||= table_name.singularize
    end

    
    module ClassMethods

      attr_writer :table_name

      def table_name
        @table_name ||= self.model_name.to_s.underscore.pluralize
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

      def model_name
        if defined? ActiveModel
          rails_model_name_method
        else
          @_model_name_namespace ||= name.split('::').last.underscore.capitalize
        end
      end

      def model_name=(name)
        @_model_name_namespace = name
      end
      

      protected ############## PROTECTED #############

      def rails_model_name_method
        @_model_name ||= begin
          @_model_name_namespace ||= self.parents.detect do |n|
            n.respond_to?(:use_relative_model_naming?) && n.use_relative_model_naming?
          end
          ActiveModel::Name.new(self, @_model_name_namespace)
        end
      end

    end

  end

end
