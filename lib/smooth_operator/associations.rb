require "smooth_operator/associations/has_many_relation"
require "smooth_operator/associations/association_reflection"

module SmoothOperator
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
        has_many_relation = instance_variable_get("@#{association}")

        if has_many_relation.nil?
          has_many_relation = HasManyRelation.new(self, association)

          instance_variable_set("@#{association}", has_many_relation)
        end

        has_many_relation.send(:refresh)

        has_many_relation
      end
    end

    def define_single_association_method(reflection, association)
      define_method(association) { internal_data_get(association.to_s) }

      define_method("build_#{association}") do |attributes = {}|
        new_instance = reflection.klass.new(attributes)

        internal_data_push(association, new_instance)

        new_instance
      end
    end

    def define_attributes_setter_methods(reflection, association)
      define_method("#{association}_attributes=") do |attributes|
        instance_variable_set("@#{association}_attributes", attributes)

        attributes = attributes.values if reflection.has_many?

        internal_data_push(association.to_s, attributes)
      end
    end

    def parse_options(options, default_options)
      options = options.is_a?(Hash) ? options.merge(default_options) : default_options

      Helpers.symbolyze_keys(options)
    end

  end
end
