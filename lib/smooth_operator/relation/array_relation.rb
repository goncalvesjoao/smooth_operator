require "smooth_operator/relation/single_relation"

module SmoothOperator
  module Relation
    class ArrayRelation < SingleRelation

      def data
        super || []
      end

      def reload
        "TODO"
      end

    end
  end
end
