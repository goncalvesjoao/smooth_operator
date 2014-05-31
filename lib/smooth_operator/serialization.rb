module SmoothOperator

  module Serialization

    def to_hash(options = nil)
      Helpers.symbolyze_keys(serializable_hash(options) || {})
    end

    # alias :attributes :to_hash
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

      _attribute_names(options).each do |attribute_name|
        hash[attribute_name] = _read_attribute_for_hashing(attribute_name, options)
      end

      method_names(options).each do |method_name|
        hash[method_name.to_s] = send(method_name)
      end

      hash
    end


    protected ##################### PROTECTED ###################

    # TODO: COMPLEX METHOD
    def _attribute_names(options)
      attribute_names = internal_data.keys.sort

      if only = options[:only]
        attribute_names &= [*only].map(&:to_s)
      elsif except = options[:except]
        attribute_names -= [*except].map(&:to_s)
      end

      attribute_names
    end

    def method_names(options)
      [*options[:methods]].select { |n| respond_to?(n) }
    end

    def _read_attribute_for_hashing(attribute_name, options)
      object = read_attribute_for_serialization(attribute_name)

      _options = options[attribute_name] || options[attribute_name.to_sym]

      if object.is_a?(Array)
        object.map { |array_entry| _attribute_to_hash(array_entry, _options) }
      else
        _attribute_to_hash(object, _options)
      end
    end

    def _attribute_to_hash(object, options = nil)
      if object.respond_to?(:serializable_hash)
        Helpers.symbolyze_keys(object.serializable_hash(options))
      else
        object
      end
    end

  end

end
