require 'smooth_operator/attributes/base'
require 'smooth_operator/attributes/dirty'
require 'smooth_operator/attributes/normal'

module SmoothOperator

  module AttributeAssignment

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      attr_writer :unknown_hash_class

      def unknown_hash_class
        Helpers.get_instance_variable(self, :unknown_hash_class, ::OpenStruct)
      end

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

      def dirty_attributes
        @dirty_attributes = true
      end

      def dirty_attributes?
        @dirty_attributes
      end

    end

    def initialize(attributes = {}, options = {})
      @_options = {}

      before_initialize(attributes, options)

      assign_attributes attributes, options

      after_initialize(attributes, options)
    end

    attr_reader :_options, :_meta_data


    def assign_attributes(_attributes = {}, options = {})
      return nil unless _attributes.is_a?(Hash)

      attributes = _attributes = Helpers.stringify_keys(_attributes)

      if _attributes.include?(self.class.resource_name)
        attributes = _attributes.delete(self.class.resource_name)
        @_meta_data = _attributes
      end

      options.each { |key, value| @_options[key] = value } if options.is_a?(Hash)

      attributes.each { |name, value| push_to_internal_data(name, value, true) }
    end

    def parent_object
      _options[:parent_object]
    end

    def has_data_from_server
      _options[:from_server] == true
    end

    alias :from_server :has_data_from_server

    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def before_initialize(attributes, options); end

    def after_initialize(attributes, options); end

    def allowed_attribute(attribute)
      if !self.class.attributes_white_list.empty?
        self.class.attributes_white_list.include?(attribute)
      elsif !self.class.attributes_black_list.empty?
        !self.class.attributes_black_list.include?(attribute)
      else
        true
      end
    end

  end
end
