module SmoothOperator
  module Persistence

    def self.included(base)
      base.extend(ClassMethods)
    end

    attr_reader :last_remote_call

    def new_record?(ignore_cache = false)
      return @new_record if !ignore_cache && defined?(@new_record)

      @new_record = Helpers.has_primary_key?(self)
    end

    def marked_for_destruction?(ignore_cache = false)
      if !ignore_cache && defined?(@marked_for_destruction)
        return @marked_for_destruction
      end

      _destroy = internal_data_get(self.class.destroy_key)

      @marked_for_destruction = TypeCasting::TRUE_VALUES.include?(_destroy)
    end

    def destroyed?
      return @destroyed if defined?(@destroyed)

      @destroyed = false
    end

    def persisted?
      !(new_record? || destroyed?)
    end

    def known_attribute?(attribute)
      super ||
      [self.class.primary_key, self.class.destroy_key].include?(attribute.to_s)
    end

    def reload(relative_path = nil, data = {}, options = {})
      if Helpers.blank?(relative_path) && Helpers.has_primary_key?(self)
        raise 'UnknownPath'
      end

      make_a_persistence_call(:reload, relative_path, data, options) do |remote_call|
        block_given? ? yield(remote_call) : remote_call.status
      end
    end

    def save(relative_path = nil, data = {}, options = {})
      resource_data = resource_data_for_server(data)

      method = new_record? ? :create : :update

      make_a_persistence_call(method, relative_path, resource_data, options) do |remote_call|
        @new_record = false if method == :create && remote_call.status

        block_given? ? yield(remote_call) : remote_call.status
      end
    end

    def destroy(relative_path = nil, data = {}, options = {})
      return false unless persisted?

      make_a_persistence_call(:destroy, relative_path, data, options) do |remote_call|
        @destroyed = true if remote_call.status

        block_given? ? yield(remote_call) : remote_call.status
      end
    end

    def save!(relative_path = nil, data = {}, options = {})
      save(relative_path, data, options) do |remote_call|
        block_given? ? yield(remote_call) : remote_call.status
      end || raise('RecordNotSaved')
    end

    protected ######################### PROTECTED ##################

    def internal_data_for_server
      data = self.class.get_option(:internal_data_for_server, false)

      if data == false
        serializable_hash.dup.tap { |hash| hash.delete(self.class.primary_key) }
      else
        data
      end
    end

    def resource_data_for_server(data)
      resource_data =
        self.class.get_option(:resource_data_for_server, false, data)

      if resource_data == false
        data = Helpers.stringify_keys(data)
        resource_data = Helpers.stringify_keys(internal_data_for_server)

        { self.class.resource_name.to_s => resource_data }.merge(data)
      else
        resource_data
      end
    end

    private ##################### PRIVATE ##################

    def make_a_persistence_call(method, relative_path, data, options)
      options ||= {}

      http_verb = options[:http_verb] || self.class.http_verb_for(method)

      make_the_call(http_verb, relative_path, data, options) do |remote_call|
        @last_remote_call = remote_call

        if !@last_remote_call.error? && @last_remote_call.parsed_response.is_a?(Hash)
          assign_attributes @last_remote_call.parsed_response, data_from_server: true
        end

        yield(remote_call)
      end
    end

    module ClassMethods

      METHODS_VS_HTTP_VERBS = { reload: :get, create: :post, update: :put, destroy: :delete }

      def http_verb_for(method)
        get_option "#{method}_http_verb".to_sym, METHODS_VS_HTTP_VERBS[method]
      end

      def primary_key
        get_option :primary_key, 'id'
      end

      def destroy_key
        get_option :destroy_key, '_destroy'
      end

      def create(attributes = nil, relative_path = nil, data = {}, options = {})
        new(attributes).tap do |object|
          object.save(relative_path, data, options)
        end
      end

    end
  end
end
