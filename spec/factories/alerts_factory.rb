FactoryGirl.define do
  factory :alert do
    factory :test_alert_1 do
      additional_emails 'rsanchezti@gmail.com'
    end
    
    factory :test_alert_2 do
      additional_emails 'rsanchezti@gmail.com'
    end
    
    factory :test_alert_3 do
      additional_emails 'rsanchezti@gmail.com'
    end
  end
end