module SmoothOperator

  module Helpers

    extend self

    def symbolyze_keys(hash)
      hash.keys.reduce({ }) do |acc, key|
        acc[key.to_sym] = hash[key]
        acc
      end
    end
    
    def setter_method?(method)
      !! ((method.to_s) =~ /=$/)
    end

    def duplicate(object)
      object.dup rescue object
    end

    def blank?(object)
      case object
      when String
        object.to_s == ''
      when Array
        object.empty?
      else
        object.nil?
      end
    end

    def present?(object)
      !blank?(object)
    end
    
  end
  
end