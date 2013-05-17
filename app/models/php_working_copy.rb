class PhpWorkingCopy < WorkingCopy
	set_table_name 'working_copies'

	def serv_restart
		session = self.remote_server.start_session

		result = self.remote_server.run_command("/etc/init.d/httpd restart", session, true)

		self.remote_server.end_session(session)
	end

	def detect_changes(result)
		self.flags = Hash.new
	end

end
