module SmoothOperator
  module Relation
    class SingleRelation < ::SimpleDelegator

      attr_reader :object, :relation_name

      def initialize(object, relation_name)
        @object, @relation_name = object, relation_name
        super(object)
      end

      def persisted?
        object.nil? ? false : object.persisted?
      end

    end
  end
end
