module SmoothOperator

  module Helpers

    extend self

    def safe_call(object, method, *args)
      if object.respond_to?(method)
        object.send(method, *args)
      else
        false
      end
    end

    def super_method(object, method_name, *args)
      object.superclass.send(method_name, *args) if object.superclass.respond_to?(method_name)
    end

    def get_instance_variable(object, variable, default_value)
      instance_var = object.instance_variable_get("@#{variable}")

      return instance_var unless instance_var.nil?

      instance_var = (super_method(object, variable) || default_value)

      if instance_var.class == Class
        object.instance_variable_set("@#{variable}", instance_var)
      else
        object.instance_variable_set("@#{variable}", duplicate(instance_var))
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

    def plural?(string)
      string = string.to_s
      string == string.pluralize
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

    def absolute_path?(string)
      present?(string) && string[0] == '/'
    end

    def remove_initial_slash(string)
      string[1..-1]
    end

  end
end
