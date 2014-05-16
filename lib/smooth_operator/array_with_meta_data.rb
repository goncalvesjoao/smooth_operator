module SmoothOperator

  class ArrayWithMetaData < OpenStruct::Base
    
    extend Forwardable

    include Enumerable

    attr_reader :meta_data, :internal_array, :object_class

    def_delegators :internal_array, :length, :<<, :[]

    def initialize(attributes, object_class)
      _attributes = attributes.dup

      @object_class = object_class
      _resources_name = object_class.resources_name

      @internal_array = [*_attributes[_resources_name]].map { |array_entry| object_class.new(array_entry).tap { |object| object.reloaded = true } }
      _attributes.delete(_resources_name)

      @meta_data = _attributes
    end


    def each
      internal_array.each { |array_entry| yield array_entry }
    end
    
    def method_missing(method, *args, &block)
      _method = method.to_s
      meta_data.include?(_method) ? meta_data[_method] : super
    end

  end

end
