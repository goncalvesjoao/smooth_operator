module SmoothOperator
  module AttributeAssignment

    def initialize(attributes = {}, options = {})
      @_options = {}

      before_initialize(attributes, options)

      assign_attributes(attributes, options)

      after_initialize(attributes, options)
    end

    attr_reader :_options, :_meta_data

    def assign_attributes(attributes = {}, options = {})
      return nil unless attributes.is_a?(Hash)

      attributes = _extract_attributes(attributes)

      induce_errors(attributes.delete(self.class.errors_key))

      @_options.merge!(options) if options.is_a? Hash

      attributes.each do |name, value|
        next unless allowed_attribute(name)

        if respond_to?("#{name}=")
          send("#{name}=", value)
        else
          internal_data_push(name, value)
        end
      end
    end

    protected ################# PROTECTED METHODS DOWN BELOW ###################

    def _extract_attributes(attributes)
      _attributes = Helpers.stringify_keys(attributes)

      if _attributes.include?(self.class.resource_name)
        attributes = _attributes.delete(self.class.resource_name)
        @_meta_data = _attributes
      else
        attributes = _attributes
        @_meta_data = {}
      end

      attributes
    end

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

    end

  end
end
