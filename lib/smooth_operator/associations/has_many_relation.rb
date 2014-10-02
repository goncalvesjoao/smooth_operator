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
        new_entries = if attributes.is_a?(Array)
          attributes.map { |attrs| new(attrs) }
        else
          [new(attributes)]
        end

        new_array = get_array

        new_array.push *new_entries

        object.send("#{association}=", new_array)

        attributes.is_a?(Array) ? new_entries : new_entries.first
      end

      def attributes
        get_array.map(&:attributes)
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
