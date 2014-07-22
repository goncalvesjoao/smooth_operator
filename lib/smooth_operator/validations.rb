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
        get_option :errors_key, 'errors'
      end

    end

  end
end
