class FileMailer < ActionMailer::Base
	default from: "ServerManager <support@innovaxp.com>"

	def outdated_versions(data, email_addresses)
		@data = data
    
    email_addresses.each do |email_address|
  		mail( :to => email_address, :subject => _("Detected outdated versions.") )
    end
	end


end
