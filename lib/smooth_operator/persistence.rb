module SmoothOperator

  module Persistence

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def methods_vs_http_verbs
        @methods_vs_http_verbs ||= { reload: :get, create: :post, update: :put, destroy: :delete }
      end

      [:reload, :create, :update, :destroy].each do |method|
        define_method("#{method}_http_verb=") { |http_verb| methods_vs_http_verbs[method] = http_verb }
      end

      def create(attributes = nil, relative_path = nil, data = {}, options = {})
        new(attributes).tap { |object| object.save(relative_path, data, options) }
      end

    end


    def reload(relative_path = nil, data = {}, options = {})
      raise 'UnknownPath' if Helpers.blank?(relative_path) && (!respond_to?(:id) || Helpers.blank?(id))

      make_the_call(*persistent_method_args(:reload, relative_path, data, options)) do |remote_call|
        block_given? ? yield(remote_call) : remote_call.status
      end
    end

    def new_record?
      return @new_record if defined?(@new_record)

      @new_record = Helpers.blank?(get_internal_data("id"))
    end

    def destroyed?
      return @destroyed if defined?(@destroyed)

      @destroyed = false
    end

    def persisted?
      !(new_record? || destroyed?)
    end

    def save(relative_path = nil, data = {}, options = {})
      data = data_with_object_attributes(data, options)

      if new_record?
        create(relative_path, data, options) { |remote_call| block_given? ? yield(remote_call) : remote_call.status }
      else
        update(relative_path, data, options) { |remote_call| block_given? ? yield(remote_call) : remote_call.status }
      end
    end

    def save!(relative_path = nil, data = {}, options = {})
      save(relative_path, data, options) do |remote_call|
        block_given? ? yield(remote_call) : remote_call.status
      end || raise('RecordNotSaved')
    end

    def destroy(relative_path = nil, data = {}, options = {})
      return false unless persisted?

      make_the_call(*persistent_method_args(:destroy, relative_path, data, options)) do |remote_call|
        @destroyed = true if remote_call.status

        block_given? ? yield(remote_call) : remote_call.status
      end
    end


    protected ######################### PROTECTED ##################

    def create(relative_path, data, options)
      make_the_call(http_verb_for(:create, options), relative_path, data, options) do |remote_call|
        @new_record = false if remote_call.status

        block_given? ? yield(remote_call) : remote_call
      end
    end

    def update(relative_path, data, options)
      make_the_call(*persistent_method_args(:update, relative_path, data, options)) do |remote_call|
        block_given? ? yield(remote_call) : remote_call
      end
    end

    def make_the_call(http_verb, relative_path, data, options)
      self.class.make_the_call(http_verb, relative_path, data, options) do |remote_call|
        @last_remote_call = remote_call

        returning_data = @last_remote_call.parsed_response

        if !@last_remote_call.error? && returning_data.is_a?(Hash)
          assign_attributes returning_data, from_server: true
        end

        yield(remote_call)
      end
    end


    private ##################### PRIVATE ####################

    def persistent_method_args(method, relative_path, data, options)
      options ||= {}

      if Helpers.blank?(relative_path)
        if parent_object.nil? || options[:ignore_parent] == true
          relative_path = id.to_s
        else
          options[:table_name] = ''
          relative_path = "#{parent_object.table_name}/#{parent_object.id}/#{table_name}/#{id}"
        end
      end

      [http_verb_for(method, options), relative_path, data, options]
    end

    def http_verb_for(method, options)
      options[:http_verb] || self.class.methods_vs_http_verbs[method]
    end

    def data_with_object_attributes(data, options)
      data = Helpers.stringify_keys(data)

      hash = serializable_hash(options[:serializable_options]).dup

      hash.delete('id')

      { model_name => hash }.merge(data)
    end

  end

end
