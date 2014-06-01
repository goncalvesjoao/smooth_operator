module SmoothOperator
  module Validations

    def valid?(context = nil)
      Helpers.blank?(induced_errors)
    end

    def invalid?
      !valid?
    end

    def induced_errors
      @induced_errors ||= {}
    end

    def clear_induced_errors
      @induced_errors = {}
    end

    def induce_errors(value)
      @induced_errors = value
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
