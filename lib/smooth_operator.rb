require "smooth_operator/schema"
require "smooth_operator/version"
require "smooth_operator/helpers"
require "smooth_operator/operator"
require "smooth_operator/persistence"
require "smooth_operator/translation"
require "smooth_operator/open_struct"
require "smooth_operator/http_methods"
require "smooth_operator/associations"
require "smooth_operator/finder_methods"

module SmoothOperator
  class Base < OpenStruct

    extend Schema
    extend HttpMethods
    extend Associations
    extend FinderMethods
    extend Translation if defined? I18n

    include Operator
    include HttpMethods
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
        type = self.class.attribute_type(attribute_name)

        ActiveRecord::ConnectionAdapters::Column.new(attribute_name.to_sym, type, type)
      end

      def save(relative_path = nil, data = {}, options = {})
        # clear_server_errors
        return false unless before_save

        save_result = valid? ? super : false

        # import_server_errors

        after_save if valid? && save_result

        save_result
      end

      def before_save
        true
      end

      def after_save; end

    end
  end
end
