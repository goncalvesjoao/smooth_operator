module SmoothOperator
  
  module Record

    def id
      represented_object.try(:id)
    end
  
    def new_record?
      Helpers.try_or_return(represented_object, :new_record?, true)
    end

    def persisted?
      Helpers.try_or_return(represented_object, :persisted?, false)
    end

    def save
      save_or_! { submit }
    end

    def save!(save_method = :save!)
      save_or_! { submit! }
    end

    def submit
      submit_or_!(:save)
    end

    def submit!
      submit_or_!(:save!)
    end

    def destroy
      return true if represented_object.blank?
      represented_object.destroy
    end

    def call_save_or_destroy(object, save_method)
      if object == self
        represented_object.present? ? represented_object.send(save_method) : true
      else
        save_method = :destroy if check_if_marked_for_destruction?(object)
        object.send(save_method)
      end
    end

    def clear_nested_imposed_errors
      nested_objects.each do |reflection, nested_object|
        nested_object.clear_imposed_errors

        nested_object.clear_nested_imposed_errors if nested_object.respond_to?(:clear_nested_imposed_errors)
      end
    end

    def populate_nested_imposed_errors
      nested_objects.each do |reflection, nested_object|
        next if nested_object.marked_for_destruction?
        
        nested_object.populate_imposed_errors
        
        nested_object.populate_nested_imposed_errors if nested_object.respond_to?(:populate_nested_imposed_errors)
      end
    end

    protected #################### PROTECTED METHODS DOWN BELOW ######################

    def save_or_!
      clear_imposed_errors
      clear_nested_imposed_errors
      
      before_save

      save_result = valid? ? yield : false
      
      populate_imposed_errors
      populate_nested_imposed_errors

      after_save if valid? && save_result

      save_result
    end

    def before_save; end
    def after_save; end

    def submit_or_!(save_method)
      save_result = save_or_destroy_nested_objects(save_method, :belongs_to)
      save_result = save_or_destroy_represented_object(save_method)
      save_result = save_or_destroy_nested_objects(save_method, :has_many) if save_result
      save_result = save_or_destroy_nested_objects(save_method, :has_one) if save_result
      save_result
    end

    def save_or_destroy_represented_object(save_method)
      return true if represented_object.blank?
      call_save_or_destroy(represented_object, save_method)
    end
    
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def all(*args)
        if represented_object_class.respond_to?(:all)
          represented_object_class.all(*args).map { |represented_object| self.new({}, represented_object) }
        else
          []
        end
      end

    end

    private #################### PRIVATE METHODS DOWN BELOW ######################

    def check_if_marked_for_destruction?(object)
      object.respond_to?(:marked_for_destruction?) ? object.marked_for_destruction? : false
    end

  end
  
end
