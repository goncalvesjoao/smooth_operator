module SmoothOperator

  module Helpers

    extend self

    def setter_method?(method)
      !! ((method.to_s) =~ /=$/)
    end

    def try_or_return(object, method, default_value)
      returning_value = object.try(method)
      returning_value.nil? ? default_value : returning_value
    end

    def has_errors_method?(object)
      object.present? && object.respond_to?(:errors) && !object.errors.nil?
    end
    
  end
  
end