FactoryGirl.define do
  
  factory :user, class: User do
    
    id 1
    admin true
    last_name 'Doe'
    first_name 'John'

    trait :has_my_method do
      my_method 'my_method'
    end
    factory :user_with_my_method, traits: [:has_my_method]

    trait :with_address_and_posts do
      address { { street: 'my_street' } }
      posts [{ body: 'post1' }, { body: 'post2' }]
    end
    factory :user_with_address_and_posts, traits: [:with_address_and_posts]

  end

  factory :user_filtered, class: User do
    id 1
    first_name 'John'
  end

end
