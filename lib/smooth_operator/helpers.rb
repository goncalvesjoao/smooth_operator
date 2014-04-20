module SmoothOperator

  module Helpers

    extend self

    def to_int(string)
      to_float(string).to_i
    end

    def to_float(string)
      return string if [Fixnum, Float].include?(string.class)

      return 0 if string.nil? || !string.is_a?(String)
      
      value = string.scan(/-*\d+[,.]*\d*/).flatten.map(&:to_f).first

      value.nil? ? 0 : value
    end
    
    def get_instance_variable(object, variable, default_value)
      instance_var = object.instance_variable_get("@#{variable}")

      return instance_var unless instance_var.nil?

      (object.zuper_method(variable) || default_value).dup.tap do |instance_var|
        object.instance_variable_set("@#{variable}", instance_var)
      end
    end

    def stringify_keys(hash)
      stringified_hash = {}
      hash.keys.each { |key| stringified_hash[key.to_s] = hash[key] }
      stringified_hash
    end

    def symbolyze_keys(hash)
      hash.keys.reduce({}) do |cloned_hash, key|
        cloned_hash[key.to_sym] = hash[key]
        cloned_hash
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