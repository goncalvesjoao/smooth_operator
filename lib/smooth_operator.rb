require "smooth_operator/version"
require "smooth_operator/helpers"
require "smooth_operator/operator"
require "smooth_operator/persistence"
require "smooth_operator/translation"
require "smooth_operator/open_struct"
require "smooth_operator/finder_methods"
require "smooth_operator/relation/associations"

module SmoothOperator
  class Base < OpenStruct::Base

    extend FinderMethods
    extend Relation::Associations
    extend Translation if defined? I18n

    include Operator
    include Persistence
    include FinderMethods

    self.strict_behaviour = true

    def self.smooth_operator?
      true
    end

  end

  if defined?(ActiveModel)
    class Rails < Base

      include ActiveModel::Validations
      include ActiveModel::Validations::Callbacks
      include ActiveModel::Conversion

      def column_for_attribute(attribute_name)
        type = get_attribute_type(attribute_name)

        ActiveRecord::ConnectionAdapters::Column.new(attribute_name.to_sym, type, type)
      end

    end
  end
end
