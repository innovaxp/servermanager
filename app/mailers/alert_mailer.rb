class AlertMailer < ActionMailer::Base
  default from: "ServerManager <info@innovaxp.com>"
  
  def backup_alert(email,backup_configuration,remote_server) 
    @remoteserver = remote_server
	  @backup_cofiguration = backup_configuration
    mail(:to => email, :subject => _("New backup"))
  end
  
  def cron_alert(email, options,remote_server) 
	  @options = options
    @remote_server = remote_server
    mail(:to => email, :subject => _("New cron alert"))
    
  end
  
  def dns_alert(email, options,remote_server) 
    @options = options
    @remoteserver = remote_server
    mail(:to => email, :subject => _("New dns alert"))
    
end

  
  def account_alert (email,options,remote_server) 
   @remote_server = remote_server
   @options = options
   mail(:to => email, :subject => _("New account"))
    
  end
  
  
  def email_account_alert(email, options, remote_server) 
    @options = options  
    @remoteserver = remote_server
    mail(:to => email, :subject => _("New email account"))
    
  end

  def email_forwader_alert(email, options, remote_server)  
    @options = options 
    @remoteserver = remote_server
    mail(:to => email, :subject => _("New forwader"))  
  end
 end
  
  