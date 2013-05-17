class AdminController < ApplicationController
	before_filter :authorize
	protect_from_forgery

	def index
  	end

	protected
		def authorize
			retval = super
			if retval != 1
				unless session[:role] == "admin"
					redirect_to users_url, :alert => "Admin permissions required"
				end
			end
		end


    #prueba

end
