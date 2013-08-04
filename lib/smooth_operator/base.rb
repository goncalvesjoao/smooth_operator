require "smooth_operator/operator"
require "smooth_operator/orm"

module SmoothOperator
  class Base < OpenStruct

    include SmoothOperator::Operator
    include SmoothOperator::ORM

    def table_to_hash
      @table
    end

    def as_json(options = nil)
	    @table.as_json(options)
	  end

    def self.nested_objects_classes(hash)
      hash.each do |nested_object_symbol, nested_object_class|
        define_method(nested_object_symbol.to_s) do
          get_nested_object_variable(nested_object_symbol, nested_object_class)
        end
      end
    end

    private #---------------------------- private

    def get_nested_object_variable(nested_object_symbol, nested_object_class)
      nested_object_variable = instance_variable_get("@#{nested_object_symbol}")

      return nested_object_variable if nested_object_variable.present?

      nested_object_variable = initialize_nested_object_variable(table_to_hash[nested_object_symbol], nested_object_class, nested_object_symbol)

      instance_variable_set("@#{nested_object_symbol}", nested_object_variable)

      nested_object_variable
    end

    def initialize_nested_object_variable(attributes, nested_object_class, nested_object_symbol)
      if attributes.kind_of? Array
        attributes.map { |_attributes| get_nested_object(_attributes, nested_object_class, nested_object_symbol) }
      else
        get_nested_object(attributes, nested_object_class, nested_object_symbol)
      end
    end

    def get_nested_object(nested_objects_attributes, nested_object_class, nested_object_symbol)
      if nested_objects_attributes.blank?
        plural?(nested_object_symbol) ? [] : nil
      else
        nested_object_class.new(nested_objects_attributes)
      end
    end

    def plural?(string)
      string = string.to_s
      string == string.pluralize
    end

  end
end
