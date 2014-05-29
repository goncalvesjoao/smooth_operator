module SmoothOperator
  class ArrayWithMetaData < ::SimpleDelegator

    attr_reader :meta_data, :internal_array

    def initialize(attributes, object_class)
      _attributes, _resources_name = attributes.dup, object_class.resources_name

      @internal_array = [*_attributes[_resources_name]].map { |array_entry| object_class.new(array_entry).tap { |object| object.reloaded = true } }
      _attributes.delete(_resources_name)

      @meta_data = _attributes

      super(@internal_array)
    end

    def method_missing(method, *args, &block)
      _method = method.to_s
      meta_data.include?(_method) ? meta_data[_method] : super
    end

  end
end
