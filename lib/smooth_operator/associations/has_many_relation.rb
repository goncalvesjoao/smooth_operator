module SmoothOperator
  module Associations
    class HasManyRelation < SimpleDelegator

      attr_reader :object, :association

      def initialize(object, association)
        @object, @association = object, association
      end

      def reload
        "TODO"
      end

      def new(attributes = {})
        object.class.reflect_on_association(association).klass.new(attributes)
      end

      def build(attributes = {})
        new_array, new_array_entry = get_array, new(attributes)

        new_array.push new_array_entry

        object.send("#{association}=", new_array)

        new_array_entry
      end

      undef :is_a?

      protected ############### PROTECTED ###############

      def get_array
        data = object.internal_data_get(association.to_s)

        data.nil? ? [] : [*data]
      end

      def refresh
        __setobj__ get_array
      end

    end
  end
end
