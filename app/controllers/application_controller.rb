class ApplicationController < ActionController::Base
  protect_from_forgery

  def index    
      @from = 'index'    
  end

  
  before_filter :you_dont_have_bloody_clue

  def to_iframe
		@nobuttons = true
		return :action => params[:action]+".html", :layout => "no_layout"
	end

  protected


  def you_dont_have_bloody_clue
    klasses = [ActiveRecord::Base, ActiveRecord::Base.class]
    methods = ["session", "cookies", "params", "request"]

    methods.each do |shenanigan|
      oops = instance_variable_get(:"@_#{shenanigan}")

      klasses.each do |klass|
        klass.send(:define_method, shenanigan, proc { oops })
      end
    end

  end

  
  protected
	def authorize_admin		
		
			if session[:role] != "admin"

				redirect_to url_for(:controller => "application", :action => "index"), :alert => _("User permissions required") and return 1
			end
		
	end
	def authorize
		session[:return_to] = request.fullpath

		#@array =  ApplicationController.get_models
		#@array.each do |a|
		#	logger.info a
		#end

		unless User.find_by_id(session[:user_id])
			redirect_to login_url, :alert => "Please log in" and return 1


		end
	end

end
