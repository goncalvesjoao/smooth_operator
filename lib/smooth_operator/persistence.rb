module SmoothOperator
  module Persistence

    def self.included(base)
      base.extend(ClassMethods)
    end

    attr_reader :last_remote_call

    def get_primary_key
      get_internal_data(self.class.primary_key)
    end

    def reload(relative_path = nil, data = {}, options = {})
      raise 'UnknownPath' if Helpers.blank?(relative_path) && (!respond_to?(self.class.primary_key) || Helpers.blank?(get_primary_key))

      persistence_call(:reload, relative_path, data, options) do |remote_call|
        block_given? ? yield(remote_call) : remote_call.status
      end
    end

    def new_record?(bypass_cache = false)
      return @new_record if !bypass_cache && defined?(@new_record)

      @new_record = Helpers.blank?(get_primary_key)
    end

    def marked_for_destruction?(bypass_cache = false)
      return @marked_for_destruction if !bypass_cache && defined?(@marked_for_destruction)

      @marked_for_destruction = ["true", "1", true].include?(get_internal_data(self.class.destroy_key))
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

      persistence_call(:destroy, relative_path, data, options) do |remote_call|
        @destroyed = true if remote_call.status

        block_given? ? yield(remote_call) : remote_call.status
      end
    end


    protected ######################### PROTECTED ##################

    def create(relative_path, data, options)
      persistence_call(:create, relative_path, data, options) do |remote_call|
        @new_record = false if remote_call.status

        block_given? ? yield(remote_call) : remote_call
      end
    end

    def update(relative_path, data, options)
      persistence_call(:update, relative_path, data, options) do |remote_call|
        block_given? ? yield(remote_call) : remote_call
      end
    end

    def persistence_call(method, relative_path, data, options)
      options ||= {}

      http_verb = options[:http_verb] || self.class.methods_vs_http_verbs[method]

      make_the_call(http_verb, relative_path, data, options) do |remote_call|
        @last_remote_call = remote_call

        if !@last_remote_call.error? && @last_remote_call.parsed_response.is_a?(Hash)
          assign_attributes @last_remote_call.parsed_response, from_server: true
        end

        yield(remote_call)
      end
    end

    def data_with_object_attributes(data, options)
      data = Helpers.stringify_keys(data)

      hash = serializable_hash(options[:serializable_options]).dup

      hash.delete(self.class.primary_key)

      { self.class.resource_name => hash }.merge(data)
    end


    module ClassMethods

      METHODS_VS_HTTP_VERBS = { reload: :get, create: :post, update: :put, destroy: :delete }

      def methods_vs_http_verbs
        Helpers.get_instance_variable(self, :methods_vs_http_verbs, METHODS_VS_HTTP_VERBS.dup)
      end

      def primary_key
        Helpers.get_instance_variable(self, :primary_key, 'id')
      end

      attr_writer :primary_key

      def destroy_key
        Helpers.get_instance_variable(self, :destroy_key, '_destroy')
      end

      attr_writer :destroy_key

      METHODS_VS_HTTP_VERBS.keys.each do |method|
        define_method("#{method}_http_verb=") { |http_verb| methods_vs_http_verbs[method] = http_verb }
      end

      def create(attributes = nil, relative_path = nil, data = {}, options = {})
        new(attributes).tap { |object| object.save(relative_path, data, options) }
      end

    end
  end
end
