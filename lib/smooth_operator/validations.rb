module SmoothOperator
  module Validations

    def valid?(context = nil)
      Helpers.blank?(_internal_errors)
    end

    def invalid?
      !valid?
    end

    def _internal_errors
      @_internal_errors ||= {}
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def errors_key
        Helpers.get_instance_variable(self, :errors_key, 'errors')
      end

      attr_writer :errors_key

    end

  end
end
