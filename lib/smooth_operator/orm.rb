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

      def instantiate_each(objects)
        objects.map { |object| new(object) }
      end

      def find_each(options)
        response = get(nil, options)
        parsed_response = parse_response_or_raise_proper_exception(response)
        parsed_response.kind_of?(Array) ? instantiate_each(parsed_response) : parsed_response
      end

      def find_one(id, options)
        response = get(id, options)
        parsed_response = parse_response_or_raise_proper_exception(response)
        new(parsed_response)
      end

      def parse_response_or_raise_proper_exception(response)
        if successful_response?(response)
          response.parsed_response
        else
          SmoothOperator::Exceptions.raise_proper_exception(response)
        end
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
      @last_response = create_or_update
      import_response_errors(@last_response)
      SmoothOperator::Exceptions.raise_proper_exception(@last_response) unless self.class.successful_response?(@last_response)
      true
    end

    def destroy
      return true if new_record?
      
      @last_response = self.class.delete(self.id)
      import_response_errors(@last_response)
      self.class.successful_response?(@last_response)
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

    def hash_of_safe_content
      safe_hash = hash_of_full_content.dup

      if self.class.save_attr_white_list.present?
        safe_hash.slice!(*self.class.save_attr_white_list)
      else
        self.class.save_attr_black_list.each { |attribute| safe_hash.delete(attribute) }
      end

      safe_hash
    end

    private #-------------------------------------- private

    def create_or_update
      if new_record?
        self.class.post('', { self.class.model_name_downcase => hash_of_safe_content })
      else
        self.class.put(self.id, { self.class.model_name_downcase => hash_of_safe_content })
      end
    end

    def import_response_errors(response)
      if response.present? && response.parsed_response.include?('errors')
        self.errors = response.parsed_response['errors']
      end
    end

  end
end
