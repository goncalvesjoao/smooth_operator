module SmoothOperator
  module Relation
    class ArrayRelation

      attr_reader :object, :association

      def initialize(object, association)
        @object, @association = object, association
      end

      def method_missing(method, *args, &block)
        data.respond_to?(method) ? data.send(method, *args) : super
      end

      def data
        data = object.get_internal_data(association.to_s)

        data.nil? ? [] : [*data]
      end

      def reload
        "TODO"
      end

      def new(attributes = {})
        object.class.reflect_on_association(association).klass.new(attributes)
      end

      alias :build :new

    end
  end
end
