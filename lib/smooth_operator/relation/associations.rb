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
          define_method(association) do
            array_relation = instance_variable_get("@association")

            if array_relation.nil?
              array_relation = ArrayRelation.new(self, association)

              instance_variable_set("@association", array_relation)
            end

            array_relation
          end
        else
          define_method(association) { get_internal_data(association.to_s) }
        end

        if !reflection.has_many?
          define_method("build_#{reflection.single_name}") { |attributes = {}| reflection.klass.new(attributes) }
        end
      end

      private ####################### PRIVATE ######################

      def parse_options(options, default_options)
        options = options.is_a?(Hash) ? options.merge(default_options) : default_options

        Helpers.symbolyze_keys(options)
      end

    end
  end
end
