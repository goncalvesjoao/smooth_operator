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

  def created_subject
    @created_subject
  end

  def execute_method
    if method_to_execute.to_s =~ /create/
      attributes = attributes_for(:user_with_address_and_posts)
      
      attributes.delete(:id) if method_to_execute == :create_without_id

      @created_subject = subject_class.create(attributes, *method_arguments)
    else
      subject.send(method_to_execute, *method_arguments)
    end
  end

end