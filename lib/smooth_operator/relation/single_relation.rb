module SmoothOperator
  module Relation
    class SingleRelation

      attr_reader :object, :relation_name

      def initialize(object, relation_name)
        @object, @relation_name = object, relation_name
      end

      def method_missing(method, *args, &block)
        data.respond_to?(method) ? data.send(method, *args) : super
      end

      def data
        object.get_internal_data(relation_name)
      end

    end
  end
end
