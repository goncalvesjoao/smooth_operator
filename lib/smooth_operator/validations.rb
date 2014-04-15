module SmoothOperator

  module Validations

    def valid?(context = nil)
      internal_data['errors'].blank?
    end

    def invalid?
      !valid?
    end

  end

end
