class SessionsController < ApplicationController

	skip_before_filter :authorize

	def new
  
	end

	def autologin
		create
	end

	def create

		if user = User.authenticate_email(params[:email], params[:password])      
			session[:user_id] = user.id
			session[:owner_id] = user.owner_id
			session[:name] = user.name
			session[:email] = user.email
			session[:role] = user.rol
			

			if session[:return_to]
				redirect_to session[:return_to]
			else
				redirect_to url_for(:controller => "application", :action => "index")
			end

		else
			redirect_to login_url, :alert => _("Invalid user/password combination")
		end
	end

	def destroy
		session[:user_id] = nil
		session[:owner_id] = nil
		session[:name] = nil
		session[:email] = nil
		session[:return_to] = nil
		session[:role] = nil
		session[:user_project_id] = nil
		session[:entity_id] = nil
		redirect_to login_url, :notice => _("Logged out")
	end


end
