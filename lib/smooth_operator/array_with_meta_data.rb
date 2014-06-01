module SmoothOperator
  class ArrayWithMetaData < SimpleDelegator

    attr_reader :meta_data, :internal_array

    def initialize(attributes, object_class)
      resources_name = object_class.resources_name

      @internal_array = [*attributes[resources_name]].map do |array_entry|
        object_class.new(array_entry)
      end

      attributes.delete(resources_name)

      @meta_data = attributes

      define_metada_methods

      super(@internal_array)
    end

    protected ############# PROTECTED ###################

    def define_metada_methods
      @meta_data.keys.each do |method|
        instance_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}
            @meta_data['#{method}']
          end
        RUBY
      end
    end

  end
end
