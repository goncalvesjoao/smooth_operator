module SmoothOperator
  
  module Persistence

    module ClassMethods
      
      def create(attributes = nil, options = {}, &block)
        if attributes.is_a?(Array)
          attributes.map { |attr| create(attr, options, &block) }
        else
          new(attributes, options, &block).tap { |object| object.save }
        end
      end

    end

    def new_record?
      @new_record ||= Helpers.blank?(internal_data["id"])
    end
    
    def destroyed?
      @destroyed
    end

    def persisted?
      !(new_record? || destroyed?)
    end

    def save(*)
      create_or_update
    end

    def save!(*)
      create_or_update || raise('RecordNotSaved')
    end

    def destroy
      if persisted?
        # HTTP DELETE
      end

      @destroyed = true
    end

    protected ######################### PROTECTED ##################

    def create_or_update
      new_record? ? create : update
    end

    def update(attribute_names = @attributes.keys)
      # HTTP PUT
    end

    def create
      # HTTP POST
      # @new_record = false
      # id
    end

  end
  
end
