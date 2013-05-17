class Alert < ActiveRecord::Base
 has_many :action_alerts
 validate :check_emails

 def check_emails 
   if  self.additional_emails  != nil
   # separamos los campos de additional_email por comas si el campo no es nulo
   check_email = self.additional_emails.split(',')  
   #generamos una expresion regular para comprobar que el los campos dentre de
   # - el additional email son emails validos 
   reg_exp_email = /^[a-z0-9_\-\.]+?@[a-z0-9_\-]+?(\.[a-z0-9_\-]*)+/i
   #para cada email
   check_email.each do |email|
    email.strip!
    #si los campos no son email la funcion devuelve un mensaje de error
    if (email =~ reg_exp_email).nil?
      errors.add(:additional_emails, "must contain a comma-separated list of email addresses")
      return    
    end
    
   end
   end
  
   # Todos los emails coinciden con la exp. reg
   
   
 end
  
 def self.defined_alerts 
    return {
      'backup' => _('Backup'),
      'dns'=>_('DNS'),
      'cron'=>_('Cron Alert'),
      'account' =>_('Alert Account'),
      'email_account' =>_('Email Account'),
      'email_forwader' =>_('Email Forwader')
      } 
 end

 def self.send_notification( action , options, remote_server )
   
   
   #raise action.to_s+'/'+options.to_s+'/'+remote_server.to_s
 
   #el alert del owner_id == owner_id del remote server
   @alert = Alert.find(:first,:conditions => ['owner_id=?',remote_server])
   
   if @alert
       
       @action_alert = @alert.action_alerts.find(:first,:conditions => ['action=?',action])
       #raise @action_alert.to_yaml
       if @action_alert
         # obtengo los correos configurados en el @alert
         alert_emails = @alert.additional_emails.split(',')
         # para cada correo...
         alert_emails.each do |email|
          # extraigo la dirección de email, quitando los espacios
          email.strip!
          # envío el correo
          AlertMailer.send(action + '_alert',email,options,remote_server).deliver
       end
         
       end
   end
   
 end
end
