class Repository < ActiveRecord::Base

	validates_uniqueness_of :description
	validates_uniqueness_of :slave_location

	attr_reader :full_path

	has_many :working_copies
  has_many :user_permissions
  
	def full_path
		return APP_CONFIG['repo_location']+self.slave_location
	end

	def self.get_description_for_status(status)
		response = Hash.new

		response['A'] = _('Added')
		response['M'] = _('Modified')
		response['D'] = _('Deleted')
		response['G'] = _('Merged')

		return response[status]
	end

	def sync
		require 'xmlsimple'
		
		sync_cmd = %x[svnsync --non-interactive --trust-server-cert --sync-username "#{APP_CONFIG['repo_user']}" --sync-password "#{APP_CONFIG['repo_password']}" sync file://#{self.full_path} 2>&1]

		xml_info = %x[svn info --xml file://#{self.full_path} 2>&1]
		@repo_info = XmlSimple.xml_in(xml_info, { 'ForceArray' => false })["entry"]

		self.last_sync_date = DateTime.now
		self.current_version = @repo_info['revision']
	end

	def self.sync_all
		repositories = Repository.all

		repositories.each do |repository|
			repository.sync
			repository.save
		end
	end

	def create_repo

		if !File.directory?(self.full_path)
			Dir.mkdir(self.full_path)

			%x[svnadmin create #{self.full_path}]
			%x[echo "#!/bin/bash" > #{self.full_path}/hooks/pre-revprop-change]
			%x[echo "exit 0" >> #{self.full_path}/hooks/pre-revprop-change]
			%x[chmod a+x #{self.full_path}/hooks/pre-revprop-change]
			%x[svnsync --non-interactive --trust-server-cert --source-username "#{APP_CONFIG['repo_user']}" --source-password "#{APP_CONFIG['repo_password']}" --sync-username "#{APP_CONFIG['repo_user']}" --sync-password "#{APP_CONFIG['repo_password']}" init file://#{self.full_path} svn://#{self.master_location}]

		end

		
		self.sync

	end


end
