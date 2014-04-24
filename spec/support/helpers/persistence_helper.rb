module PersistenceHelper

  def subject_class
    UserWithAddressAndPosts::Son
  end

  def new_user
    attributes = attributes_for(:user_with_address_and_posts)
    attributes.delete(:id)

    subject_class.new attributes
  end

  def existing_user
    subject_class.new(attributes_for(:user_with_address_and_posts))
  end

  def execute_method
    _method_to_execute = (method_to_execute == :create) ? :save : method_to_execute
    
    subject.send(method_to_execute, *method_arguments)
  end

end