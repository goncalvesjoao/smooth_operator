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

    def resources_name
      @resources_name ||= self.class.resources_name.dup
    end

    def resource_name
      @resource_name ||= resources_name.singularize
    end

    
    module ClassMethods
      
      def resources_name
        @resources_name ||= self.resource_name.pluralize
      end
      attr_writer :resources_name

      def resource_name
        @resource_name ||= self.model_name.to_s.underscore.pluralize
      end
      attr_writer :resource_name

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
        return '' if @_model_name == :none

        if defined? ActiveModel
          rails_model_name_method
        else
          @_model_name ||= name.split('::').last.underscore.capitalize
        end
      end

      def model_name=(name)
        @_model_name = name
      end
      

      protected ############## PROTECTED #############

      def rails_model_name_method
        @model_name ||= begin
          namespace ||= self.parents.detect do |n|
            n.respond_to?(:use_relative_model_naming?) && n.use_relative_model_naming?
          end

          ActiveModel::Name.new(self, namespace, @_model_name).tap do |model_name|
            def model_name.human(options = {}); @klass.send(:_translate, "models.#{i18n_key}", options); end
          end
        end
      end

    end

  end

end
