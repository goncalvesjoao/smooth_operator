module SmoothOperator

  module Serialization

    def attributes
      exposed_attributes = internal_data.keys
      
      if !self.class.attributes_white_list.empty?
        exposed_attributes = self.class.attributes_white_list

      elsif !self.class.attributes_black_list.empty?
        exposed_attributes = exposed_attributes - self.class.attributes_black_list
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
      JSON serializable_hash(options)
    end

    def read_attribute_for_serialization(attribute)
      send(attribute)
    end

    def serializable_hash(options = nil)
      options ||= {}

      attribute_names = attributes.keys.sort

      if only = options[:only]
        attribute_names &= [*only].map(&:to_s)
      elsif except = options[:except]
        attribute_names -= [*except].map(&:to_s)
      end

      hash = {}
      attribute_names.each { |n| hash[n] = read_attribute_for_serialization(n) }

      method_names = [*options[:methods]].select { |n| respond_to?(n) }
      method_names.each { |method_name| hash[method_name.to_s] = send(method_name) }

      hash
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      
      def attributes_white_list
        @internal_data_white_list ||= (zuper_method(:attributes_white_list) || []).dup
      end

      def attributes_white_list_add(*getters)
        getters = getters.map(&:to_s)

        attributes_white_list.push(*getters) unless attributes_white_list.include?(getters)
      end

      def attributes_black_list
        @internal_data_black_list ||= (zuper_method(:attributes_black_list) || []).dup
      end

      def attributes_black_list_add(*getters)
        getters = getters.map(&:to_s)

        attributes_black_list.push(*getters) unless attributes_black_list.include?(getters)
      end

    end

  end

end
