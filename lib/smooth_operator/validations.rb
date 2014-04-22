module SmoothOperator

  module Validations

    def valid?(context = nil)
      Helpers.blank?(get_internal_data("errors"))
    end

    def invalid?
      !valid?
    end

  end

end
