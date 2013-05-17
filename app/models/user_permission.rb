class UserPermission < ActiveRecord::Base
	belongs_to :user
	belongs_to :repository

	def self.get_users_with_permission(repository_id)

		repo = Repository.find(:first, :conditions => ['id=?', repository_id])
		us_perms = UserPermission.find(:all, :conditions => ['repository_id=?', repo.id])

		users = []

		us_perms.each do | user_perm |
			if user_perm.read_permission
				users << user_perm.user
			end
		end

		return users

	end

end
