module SmoothOperator
  module ORM

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:attr_reader, :last_response)
    end

    module ClassMethods

      attr_writer :save_attr_black_list
      def save_attr_black_list
        @save_attr_black_list ||= [:id, :created_at, :updated_at]
      end

      attr_writer :save_attr_white_list
      def save_attr_white_list
        @save_attr_white_list ||= []
      end

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

      attr_writer :model_name
      def model_name
        @model_name ||= name.split('::').last.underscore.capitalize
      end

      def model_name_downcase
        model_name.downcase
      end

      attr_writer :table_name
      def table_name
        @table_name ||= model_name_downcase.to_s.pluralize
      end

      private #------------------------------------------------ private

      def find_each(options)
        protocol_handler_orm.find_each(options, self.class)
      end

      def find_one(id, options)
        protocol_handler_orm.find_one(id, options, self.class)
      end

    end

    def save
      begin
        save!
      rescue Exception => exception
        false
      end
    end

    def save!
      self.class.protocol_handler_orm.save!
    end

    def destroy
      self.class.protocol_handler_orm.destroy
    end

    def new_record?
      !persisted?
    end

    def persisted?
      try(:id).present?
    end

    def to_partial_path
      class_name_plural = self.class.table_name
      "#{class_name_plural}/#{class_name_plural.singularize}"
    end

    def valid?
      errors.blank?
    end

    def invalid?
      !valid?
    end

    def assign_attributes(attributes = {})
      return if attributes.blank?

      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def safe_table_to_hash
      safe_hash = table_to_hash.dup

      if self.class.save_attr_white_list.present?
        safe_hash.slice!(*self.class.save_attr_white_list)
      else
        self.class.save_attr_black_list.each { |attribute| safe_hash.delete(attribute) }
      end

      safe_hash
    end

  end
end
