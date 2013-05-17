FactoryGirl.define do
  factory :user do
    factory :test_user_1 do
      name "user1"
      password "1234"
      email 'rsanchezti@gmail.com'
      active true
    end
    
    factory :test_user_2 do
      name "user2"
      password "1234"
      email 'rsanchezti@gmail.com'
      active true
    end
    
    factory :test_user_3 do
      name "user3"
      password "1234"
      email 'rsanchezti@gmail.com'
      active false
    end
  end
end
