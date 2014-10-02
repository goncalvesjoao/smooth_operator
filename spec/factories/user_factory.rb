FactoryGirl.define do

  factory :user, class: User::Base do

    id 1
    admin true
    last_name 'Doe'
    first_name 'John'

    trait :with_address_and_posts do
      address { { street: 'my_street' } }
      # posts [{ id: 1, body: 'post1' }, { id: 2, body: 'post2' }]
      posts [{ id: 1 }, { id: 2 }]
    end
    factory :user_with_address_and_posts, traits: [:with_address_and_posts]

    trait :has_my_method do
      my_method 'my_method'
    end
    factory :user_with_my_method, traits: [:with_address_and_posts, :has_my_method]

    trait :with_complex_hash do
      alarms [{
        :action=>"AMQP",
        :attach=>"amqp:bus/routing_key",
        :description=>{"alarm_id"=>"542d2cd24a756e6006000000", "alarm_type"=>"MedicationAlarm", "medicine_id"=>"25", "medicine_type"=>"medicine", "body"=>""},
        :trigger=>{:positive=>false, :relative=>"START", :value=>"RELATIVE"}
      }]
      recurrence_rules [
        {:by_hour=>[0], :by_minute=>[30], :by_weekday=>[], :cycle=>nil, :frequency=>"DAILY", :interval=>1, :repeat_until=>nil},
        {:by_hour=>[1], :by_minute=>[0], :by_weekday=>[], :cycle=>nil, :frequency=>"DAILY", :interval=>1, :repeat_until=>nil}
      ]
    end
    factory :user_with_complex_hash, traits: [:with_complex_hash]

  end

  factory :white_list, class: User::Base do
    id 1
    first_name 'John'
  end

  factory :black_list, class: User::Base do
    admin true
    last_name 'Doe'
  end

end
