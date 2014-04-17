module SmoothOperator

  module ModelSchema

    def self.included(base)
      base.extend(ClassMethods)
    end


    def known_attributes
      @known_attributes ||= self.class.known_attributes
    end

    def push_to_known_attributes(attribute)
      return nil if known_attributes.include?(attribute)

      known_attributes.push attribute.to_s
    end


    module ClassMethods

      attr_accessor :table_name

      def schema(_schema)
        
      end

      def known_attributes
        @known_attributes ||= (zuper_method(:known_attributes) || []).dup
      end

    end

  end

end
