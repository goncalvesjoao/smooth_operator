module SmoothOperator
  module Relation
    class SingleRelation < ::SimpleDelegator

      attr_reader :relation_name

      def initialize(object, relation_name)
        @relation_name = relation_name
        super(object)
      end

    end
  end
end
