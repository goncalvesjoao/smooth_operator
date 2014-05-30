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

      alias :build :new

      protected ############### PROTECTED ###############

      def refresh
        data = object.get_internal_data(association.to_s)

        __setobj__(data.nil? ? [] : [*data])
      end

    end
  end
end
