FactoryGirl.define do
  factory :action_alert do
    factory :test_action_alert_1 do
      action "backup"
    end
    
    factory :test_action_alert_2 do
      action "dns"
    end
    
    factory :test_action_alert_3 do
      action "cron"
    end
    
    factory :test_action_alert_4 do
      action "account"
    end
    
    factory :test_action_alert_5 do
      action "email_account"
    end
    
    factory :test_action_alert_6 do
      action "email_forwader"
    end
  end
end
