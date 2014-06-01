require "smooth_operator/associations/reflection"

module SmoothOperator
  module Associations
    class AssociationReflection < Reflection

      attr_reader :related_reflection, :macro

      def initialize(association, related_reflection, options)
        super(association, options)

        @related_reflection, @macro = related_reflection, options[:macro]
      end

      def primary_key
        @primary_key ||= options[:primary_key] || :id
      end

      def foreign_key
        @foreign_key ||= options[:foreign_key] || foreign_key_default
      end

      def set_relational_keys(origin, destination)
        return nil if options[:standalone] == true

        if has_many? || has_one?
          set_foreign_key(destination, primary_key_of(origin))
        elsif belongs_to?
          set_foreign_key(origin, primary_key_of(destination))
        end
      end

      def set_foreign_key(object, id)
        setter = "#{foreign_key}="

        if object.respond_to?(setter)
          object.send(setter, id)
        elsif object.respond_to?("send_to_representative")
          object.send_to_representative(setter, id)
        end
      end

      def primary_key_of(object)
        object.send(primary_key)
      end

      def has_many?
        macro == :has_many
      end

      def has_one?
        macro == :has_one
      end

      def belongs_to?
        macro == :belongs_to
      end

      def collection?
        has_many?
      end

      private ################################# private

      def foreign_key_default
        if has_many? || has_one?
          "#{related_reflection.single_name}_id"
        elsif belongs_to?
          "#{single_name}_id"
        end.to_sym
      end

    end
  end
end
