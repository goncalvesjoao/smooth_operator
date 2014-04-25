module SmoothOperator

  module Serialization

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def attributes_white_list
        Helpers.get_instance_variable(self, :attributes_white_list, Set.new)
      end

      def attributes_black_list
        Helpers.get_instance_variable(self, :attributes_black_list, Set.new)
      end

      def attributes_white_list_add(*getters)
        attributes_white_list.merge getters.map(&:to_s)
      end

      def attributes_black_list_add(*getters)
        attributes_black_list.merge getters.map(&:to_s)
      end

    end


    def attributes
      exposed_attributes = internal_data.keys
      
      if !self.class.attributes_white_list.empty?
        exposed_attributes = self.class.attributes_white_list.to_a

      elsif !self.class.attributes_black_list.empty?
        exposed_attributes = exposed_attributes - self.class.attributes_black_list.to_a
      end

      exposed_attributes.reduce({}) do |hash, exposed_attribute|
        hash[exposed_attribute] = read_attribute_for_serialization(exposed_attribute)
        hash
      end
    end

    def to_hash(options = nil)
      Helpers.symbolyze_keys serializable_hash(options)
    end

    def to_json(options = nil)
      JSON(serializable_hash(options))
    end

    def read_attribute_for_serialization(attribute)
      send(attribute)
    end

    def serializable_hash(options = nil) # Code inspired in ActiveSupport#serializable_hash
      options ||= {}

      attribute_names = attributes.keys.sort

      if only = options[:only]
        attribute_names &= [*only].map(&:to_s)
      elsif except = options[:except]
        attribute_names -= [*except].map(&:to_s)
      end

      hash = {}
      attribute_names.each { |attribute_name| hash[attribute_name] = read_attribute_for_hashing(attribute_name, options) }

      method_names = [*options[:methods]].select { |n| respond_to?(n) }
      method_names.each { |method_name| hash[method_name.to_s] = send(method_name) }

      hash
    end


    protected ##################### PROTECTED ###################

    def read_attribute_for_hashing(attribute_name, options)
      object = read_attribute_for_serialization(attribute_name)

      _options = options[attribute_name] || options[attribute_name.to_sym]

      if object.is_a?(Array)
        object.map { |array_entry| attribute_to_hash(array_entry, _options) }
      else
        attribute_to_hash(object, _options)
      end
    end

    def attribute_to_hash(object, options = nil)
      if object.respond_to?(:serializable_hash)
        Helpers.symbolyze_keys(object.serializable_hash(options))
      else
        object
      end
    end

  end

end
