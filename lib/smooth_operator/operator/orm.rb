module SmoothOperator
  module Operator

    module ORM

      def self.included(base)
        base.extend(ClassMethods)
        base.send(:attr_reader, :last_response)
        base.send(:attr_reader, :exception)
      end

      module ClassMethods

        def find(id, options = {})
          if id == :all
            find_each(options)
          else
            find_one(id, options)
          end
        end

        def safe_find(id, options = {})
          begin
            find(id, options)
          rescue Exception => exception #exception.response contains the server response
            id == :all ? [] : nil
          end
        end

        def create(options = {})
          new_object = new(options)

          http_handler_orm.create({ model_name_downcase => new_object.safe_table_hash }) do |remote_call|
            new_object.send('after_create_update_or_destroy', remote_call)
          end

          new_object
        end

        private #------------------------------------------------ private

        def find_each(options)
          http_handler_orm.find_each(options) do |remote_call|
            response = remote_call.parsed_response

            objects_list = (response.kind_of?(Hash) ? response[table_name] : nil) || response
            
            remote_call.response = objects_list.kind_of?(Array) ? objects_list.map { |attributes| new(attributes) } : objects_list
          end
        end

        def find_one(id, options)
          http_handler_orm.find_one(id, options) do |remote_call|
            response = remote_call.parsed_response

            attributes = response.kind_of?(Hash) ? response[model_name_downcase] : response

            remote_call.response = new(attributes)
          end
        end

      end

      def save(options = {})
        begin
          save!(options)
        rescue Exception => exception
          send("exception=", exception)
          false
        end
      end

      def save!(options = {})
        options = build_options_for_save(options)

        if new_record?
          http_handler_orm.create(options) { |remote_call| after_create_update_or_destroy(remote_call) }
        else
          http_handler_orm.update(id, options) { |remote_call| after_create_update_or_destroy(remote_call) }
        end
      end

      def destroy(options = {})
        return true if new_record?
        
        http_handler_orm.destroy(id, options) do |remote_call|
          after_create_update_or_destroy(remote_call)
        end
      end

      # THIS SHOULD NOT BE HERE!
      def rollback(options = {})
        http_handler_orm.rollback("#{version_id}/rollback", options) do |remote_call|
          after_create_update_or_destroy(remote_call)
        end
      end

      private ####################### private #################

      def build_options_for_save(options = {})
        options ||= {}
        options[self.class.model_name_downcase] ||= safe_table_hash
        options
      end

      def after_create_update_or_destroy(remote_call)
        send("last_response=", remote_call.raw_response)
        send("exception=", remote_call.exception)
        new_attributes = remote_call.parsed_response.kind_of?(Hash) ? remote_call.parsed_response[self.class.model_name_downcase] : nil
        assign_attributes(new_attributes)
        remote_call.response = remote_call.successful_response?
      end

      def last_response=(response)
        @last_response = response
      end

      def exception=(exception)
        @exception = exception
      end

    end
    
  end
end
