ActionMailer::Base.smtp_settings = {
	:address => "smtp.sendgrid.net",
	:port => 25,
	:domain => "YOURDOMAIN",
	:authentication => :plain,
	:user_name => "YOURUSER",
	:password => "YOURPASSWORD"
}