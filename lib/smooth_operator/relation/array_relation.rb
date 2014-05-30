module SmoothOperator
  module Relation
    class ArrayRelation < ::SimpleDelegator

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

      # def method_missing(method, *args, &block)
      #   if get_array.respond_to?(method)
      #     puts "if true #{method} - #{args}"
      #     get_array.send(method, *args)
      #   else
      #     puts "if else #{method}"
      #     super
      #   end
      # end

      def get_array
        data = object.get_internal_data(association.to_s)

        data.nil? ? [] : [*data]
      end

      def refresh
        __setobj__ get_array
      end

    end
  end
end
