module SmoothOperator

  module Serialization

    def to_hash(options = nil)
      Helpers.symbolyze_keys(serializable_hash(options) || {})
    end

    def attributes; to_hash; end

    def to_json(options = nil)
      require 'json' unless defined? JSON

      JSON(serializable_hash(options) || {})
    end

    def read_attribute_for_serialization(attribute)
      send(attribute)
    end

    def serializable_hash(options = nil)
      hash = {}
      options ||= {}

      HelperMethods.attribute_names(self, options).each do |attribute_name|
        hash[attribute_name] = HelperMethods
          .read_attribute_for_hashing(self, attribute_name, options)
      end

      HelperMethods.method_names(self, options).each do |method_name|
        hash[method_name.to_s] = send(method_name)
      end

      hash
    end

    module HelperMethods

      extend self

      def attribute_names(object, options)
        attribute_names = object.internal_data.keys.sort

        if only = options[:only]
          white_list = [*only].map(&:to_s)

          attribute_names &= white_list
        elsif except = options[:except]
          black_list = [*except].map(&:to_s)

          attribute_names -= black_list
        end

        attribute_names
      end

      def method_names(object, options)
        [*options[:methods]].select { |n| object.respond_to?(n) }
      end

      def read_attribute_for_hashing(parent_object, attribute_name, options)
        object = parent_object.read_attribute_for_serialization(attribute_name)

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
end
