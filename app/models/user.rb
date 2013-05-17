class User < ActiveRecord::Base
	
	validates :name, :presence => true, :uniqueness => true, :unless => :force_submit
	validates :email, :presence => true, :uniqueness => true, :unless => :force_submit
	validate  :password_must_be_present	, :unless => :force_submit
	validates :password, :confirmation => true, :unless => :force_submit
  
	attr_accessor :force_submit
	attr_accessor :password_confirmation
	attr_reader   :password
	
  has_many :user_permissions
  
	def self.authenticate_email(email, password)
		if user = self.find_by_email(email)
	     	if user.hashed_password == encrypt_password(password, user.salt)
				return user
	    	else
				return nil
	     	end
		end
	end

  def authenticate(password)
	     	if self.hashed_password == User.encrypt_password(password, self.salt)
				return true
	    	else
				return false
	     	end
	end

	def self.encrypt_password(password, salt)
		Digest::SHA2.hexdigest(password + "wibble" + salt)
	end
	
	def password=(password)
		@password = password

		if password.present?
			generate_salt

			self.hashed_password = self.class.encrypt_password(password, self.salt)
		end
	end	
   
  def has_permision? (repository_id, permission_type = 'read')
    # If I'm the owner, I've permissions
    repo = Repository.find(:first, :conditions => ['id=?',repository_id])

    if repo.owner_id == self.id
      
      return true
    end

    # Chech user permissions
    us_permission = self.user_permissions.find(:first, :conditions => ["repository_id=?", repository_id])

    if us_permission

    	if permission_type == 'read' && us_permission.read_permission
      		return true
      	elsif permission_type == 'write' && us_permission.write_permission
      		return true
      	else
      		return false
      	end
    else
      return false
    end

  end
  
	private

	def password_must_be_present
		errors.add(:password, "Missing password") unless hashed_password.present?
	end

	def generate_salt
		self.salt = self.object_id.to_s + rand.to_s
	end

	def self.get_if_session(sesion)
		if(User.find_by_id(sesion))
			return true
		else
			return false

		end
	end

  def self.types
		us_types = Hash.new

		us_types["admin"] = "Administrator"
		us_types["user"] = "User"

		return us_types

	end
end