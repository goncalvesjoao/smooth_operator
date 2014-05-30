require "smooth_operator/relation/array_relation"
require "smooth_operator/relation/association_reflection"

module SmoothOperator
  module Relation
    module Associations

      def has_many(nested_object_name, options = {})
        accepts_nested_objects(nested_object_name, :has_many, options)
      end

      def has_one(nested_object_name, options = {})
        accepts_nested_objects(nested_object_name, :has_one, options)
      end

      def belongs_to(nested_object_name, options = {})
        accepts_nested_objects(nested_object_name, :belongs_to, options)
      end

      def reflections
        Helpers.get_instance_variable(self, :reflections, {})
      end

      def reflect_on_association(association)
        reflections[association]
      end

      def reflect_on_all_associations(macro = nil)
        macro ? reflections.values.select { |reflection| reflection.macro == macro } : reflections.values
      end

      protected ###################### PROTECTED ###################

      def accepts_nested_objects(association, macro, options = {})
        options = parse_options(options, { macro: macro })

        reflection = AssociationReflection.new(association, Reflection.new(name, {}), options)

        schema(association => reflection.klass)

        reflections.merge!(association => reflection)

        if reflection.has_many?
          define_has_many_association_method(reflection, association)
        else
          define_single_association_method(reflection, association)
        end

        self.send(:attr_reader, "#{association}_attributes".to_sym)

        define_attributes_setter_methods(reflection, association)
      end

      private ####################### PRIVATE ######################

      def define_has_many_association_method(reflection, association)
        define_method(association) do
          array_relation = instance_variable_get("@#{association}")

          if array_relation.nil?
            array_relation = ArrayRelation.new(self, association)

            instance_variable_set("@#{association}", array_relation)
          end

          array_relation.send(:refresh)

          array_relation
        end
      end

      def define_single_association_method(reflection, association)
        define_method(association) { get_internal_data(association.to_s) }

        define_method("build_#{reflection.single_name}") { |attributes = {}| reflection.klass.new(attributes) }
      end

      def define_attributes_setter_methods(reflection, association)
        define_method("#{association}_attributes=") do |attributes|
          instance_variable_set("@#{association}_attributes", attributes)

          attributes = attributes.values if reflection.has_many?

          push_to_internal_data(association.to_s, attributes)
        end
      end

      def parse_options(options, default_options)
        options = options.is_a?(Hash) ? options.merge(default_options) : default_options

        Helpers.symbolyze_keys(options)
      end

    end
  end
end
