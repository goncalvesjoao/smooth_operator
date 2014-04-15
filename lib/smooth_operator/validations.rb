module SmoothOperator

  module Validations

    def valid?(context = nil)
      Helpers.blank?(internal_data["errors"])
    end

    def invalid?
      !valid?
    end

  end

end
