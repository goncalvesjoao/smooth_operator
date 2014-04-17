FactoryGirl.define do
  
  factory :user, class: User::Base do
    id 1
    admin true
    last_name 'Doe'
    first_name 'John'

    trait :has_my_method do
      my_method 'my_method'
    end

    factory :user_with_my_method, traits: [:has_my_method]
  end

  factory :user_filtered, class: User::Base do
    id 1
    first_name 'John'
  end

  # This will use the User class (Admin would have been guessed)
  # factory :admin, class: User do
  #   first_name "Admin"
  #   last_name  "User"
  #   admin      true
  # end
end
