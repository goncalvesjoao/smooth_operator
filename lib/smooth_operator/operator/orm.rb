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

          http_handler_orm.make_the_call(:post, { model_name_downcase => new_object.safe_table_hash }, '') do |remote_call|
            new_object.send('after_create_update_or_destroy', remote_call)
          end

          new_object
        end

        protected ####################### protected #######################

        def find_each(options)
          http_handler_orm.make_the_call(:get, options, '') do |remote_call|
            objects_list = remote_call.get_attributes(table_name)
            
            if objects_list.kind_of?(Array)
              remote_call.response = objects_list.map { |attributes| new remote_call.get_attributes(model_name_downcase, attributes) }
            else
              remote_call.response = objects_list
            end
          end
        end

        def find_one(id, options)
          http_handler_orm.make_the_call(:get, options, id) do |remote_call|
            remote_call.response = new remote_call.get_attributes(model_name_downcase)
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
          http_handler_orm.make_the_call(:post, options, '') { |remote_call| after_create_update_or_destroy(remote_call) }
        else
          http_handler_orm.make_the_call(:put, options, id) { |remote_call| after_create_update_or_destroy(remote_call) }
        end
      end

      def destroy(options = {})
        return true if new_record?
        
        http_handler_orm.make_the_call(:delete, options, id) do |remote_call|
          after_create_update_or_destroy(remote_call)
        end
      end

      private ####################### private #######################

      def build_options_for_save(options = {})
        options ||= {}
        options[self.class.model_name_downcase] ||= safe_table_hash
        options
      end

      def after_create_update_or_destroy(remote_call)
        new_attributes = remote_call.get_attributes(self.class.model_name_downcase)
        assign_attributes(new_attributes)
        set_raw_response_exception_and_build_proper_response(remote_call)
      end

      def set_raw_response_exception_and_build_proper_response(remote_call)
        send("last_response=", remote_call.raw_response)
        send("exception=", remote_call.exception)
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
