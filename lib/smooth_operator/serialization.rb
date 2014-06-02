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
      method_names = HelperMethods.method_names(self, options)
      attribute_names = HelperMethods.attribute_names(self, options)

      attribute_names.each do |attribute_name|
        attribute_name, attribute_value = HelperMethods
          .serialize_normal_or_rails_way(self, attribute_name, options)

        hash[attribute_name] = attribute_value
      end

      method_names.each do |method_name|
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

      def serialize_normal_or_rails_way(object, attribute_name, options)
        _attribute_name, attribute_sym = attribute_name, attribute_name.to_sym

        reflection = object.class.reflect_on_association(attribute_sym)

        attribute_options = options[attribute_sym]

        if reflection && reflection.rails_serialization?
          attribute_value = serialize_has_many_attribute(object, reflection, attribute_name, attribute_options)

          _attribute_name = "#{attribute_name}_attributes"
        end

        attribute_value ||= serialize_normal_attribute(object, attribute_name, attribute_options)

        [_attribute_name, attribute_value]
      end

      def serialize_has_many_attribute(parent_object, reflection, attribute_name, options)
        return nil unless reflection.has_many?

        object = parent_object.read_attribute_for_serialization(attribute_name)

        object.reduce({}) do |hash, array_entry|
          id = Helpers.present?(array_entry.id) ? array_entry.id : Helpers.generated_id

          hash[id.to_s] = attribute_to_hash(array_entry, options)

          hash
        end
      end

      def serialize_normal_attribute(parent_object, attribute_name, options)
        object = parent_object.read_attribute_for_serialization(attribute_name)

        if object.is_a?(Array)
          object.map { |array_entry| attribute_to_hash(array_entry, options) }
        else
          attribute_to_hash(object, options)
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
