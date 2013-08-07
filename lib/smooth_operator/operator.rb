require "smooth_operator/operator/base"
require "smooth_operator/operator/remote_call"
require "smooth_operator/http_handlers"
require "smooth_operator/operator/orm"

module SmoothOperator
  module Operator

    def self.included(base)
      base.extend(ClassMethods)

      base.class_eval do
        include SmoothOperator::Operator::Base
        include SmoothOperator::Operator::ORM
      end
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

    def safe_table_hash
      safe_hash = table_hash.dup

      if self.class.save_attr_white_list.present?
        safe_hash.slice!(*self.class.save_attr_white_list)
      else
        self.class.save_attr_black_list.each { |attribute| safe_hash.delete(attribute) }
      end

      safe_hash
    end

    module ClassMethods

      attr_writer :save_attr_black_list
      def save_attr_black_list
        @save_attr_black_list ||= [:id, :created_at, :updated_at, :errors]
      end

      attr_writer :save_attr_white_list
      def save_attr_white_list
        @save_attr_white_list ||= []
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

    end
    
  end
end
