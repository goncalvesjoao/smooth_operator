module SmoothOperator

  module Serialization

    def attributes; to_hash; end

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

      attribute_names = internal_data.keys.sort

      if only = options[:only]
        attribute_names &= [*only].map(&:to_s)
      elsif except = options[:except]
        attribute_names -= [*except].map(&:to_s)
      end

      method_names = [*options[:methods]].select { |n| respond_to?(n) }

      hash = {}
      
      attribute_names.each { |attribute_name| hash[attribute_name] = read_attribute_for_hashing(attribute_name, options) }
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
