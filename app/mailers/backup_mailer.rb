class BackupMailer < ActionMailer::Base
	default from: "ServerManager <support@innovaxp.com>"

	def success(backup, email_address)
		@backup = backup
		@backup_configuration = backup.backup_configuration

		mail( :to => email_address, :subject => sprintf(_("Periodically backup for %s finished"), @backup_configuration.remote_server.description.to_s) )

	end

	def failed_upload(backup, email_address)
		@backup = backup
		@backup_configuration = backup.backup_configuration
		
		mail( :to => email_address, :subject => sprintf(_("Periodically backup for %s finished with errors."), @backup_configuration.remote_server.description.to_s) )
		
	end

	def failed(backup, email_address)
		@backup = backup
		@backup_configuration = backup.backup_configuration

		mail( :to => email_address, :subject => sprintf(_("Periodically backup for %s failed."), @backup_configuration.remote_server.description.to_s) )

	end
end
