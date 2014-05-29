require "smooth_operator/relation/array_relation"
require "smooth_operator/relation/association_reflection"

module SmoothOperator
  module Relation
    module Associations

      def relations
        @relations ||= {}
      end

      def get_relation(relation_name)
        relations[relation_name] ||= self.class.build_relation(relation_name, get_internal_data(relation_name))
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

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

        def build_relation(relation_name, data)
          if reflections[relation_name.to_sym].has_many?
            ArrayRelation.new(data || [], relation_name)
          else
            Helpers.present?(data) ? SingleRelation.new(data, relation_name) : nil
          end
        end

        protected ###################### PROTECTED ###################

        def accepts_nested_objects(nested_object_name, macro, options = {})
          options = parse_options(options, { macro: macro })

          reflection = AssociationReflection.new(nested_object_name, Reflection.new(name, {}), options)

          reflections.merge!(nested_object_name => reflection)

          schema(nested_object_name => reflection.klass)
        end

        private ####################### PRIVATE ######################

        def parse_options(options, default_options)
          options = options.is_a?(Hash) ? options.merge(default_options) : default_options

          Helpers.symbolyze_keys(options)
        end

      end
    end
  end
end
