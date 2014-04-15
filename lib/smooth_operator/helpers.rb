module SmoothOperator

  module Helpers

    extend self

    def setter_method?(method)
      !! ((method.to_s) =~ /=$/)
    end
    
  end
  
end