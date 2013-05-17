require "spec_helper"

describe AlertMailer do
  context "Send an email" do
    before{
      @user_1 = FactoryGirl.create(:test_user_1)
      @action_alert_backup = FactoryGirl.create(:test_action_alert_1)
      @action_alert_dns = FactoryGirl.create(:test_action_alert_2)
      @action_alert_cron = FactoryGirl.create(:test_action_alert_3)
      @action_alert_account = FactoryGirl.create(:test_action_alert_4)
      @action_alert_email_account = FactoryGirl.create(:test_action_alert_5)
      @action_alert_email_forwader = FactoryGirl.create(:test_action_alert_6)
      
      @alert = FactoryGirl.create(:test_alert_1)
      
      @remote_server = FactoryGirl.create(:test_remote_server_1)
      
      #associations
      
      @remote_server.owner_id = @user_1.id
      
      @remote_server.save
      
      @alert.owner_id = @user_1.id
      
      @alert.save
      
      @action_alert_backup.alert_id = @alert.id
      @action_alert_dns.alert_id = @alert.id
      @action_alert_cron.alert_id = @alert.id
      @action_alert_account.alert_id = @alert.id
      @action_alert_email_account.alert_id = @alert.id
      @action_alert_email_forwader.alert_id = @alert.id
      
      @action_alert_backup.save
      @action_alert_dns.save
      @action_alert_cron.save
      @action_alert_account.save
      @action_alert_email_account.save
      @action_alert_email_forwader.save
      
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
      
    }
    
    it "all marked actions_alerts" do
    
      options = {'minute' => '0',
                'hour' => '0',
                'day' => '0',
                'weekday' => '0',
                'month' => '1',
                'command' => '',
                'active' => '0'
     }
      
      Alert.send_notification(@action_alert_cron.action, options,@remote_server)
      ActionMailer::Base.deliveries.empty?.should be_false
      ActionMailer::Base.deliveries.last.to.should == @alert.additional_emails.split(',')
      
      
    end
    
    it "no marked actions_alerts" do 
      
      @alert.action_alerts.destroy_all
      
       options = {'minute' => '0',
                  'hour' => '0',
                  'day' => '0',
                  'weekday' => '0',
                  'month' => '0',
                  'command' => '',
                  'active' => '0'
       }

      Alert.send_notification("cron", options,@remote_server)
      ActionMailer::Base.deliveries.should be_empty
       
      
    end
    
  end
end