class UsersController < ApplicationController
  # GET /users
  # GET /users.json
  protect_from_forgery :only => [:create, :update, :destroy]
  #before_filter :authorize, :only => [:update,:show,:edit,:destroy]
  before_filter :authorize_admin
  skip_before_filter :authorize_admin, :only => [:new, :create]
  #test with branches

  before_filter :set_section

  def set_section
    @section = 'users'
  end
  
  def index
    @users = User.find_all_by_owner_id(session[:user_id])
    @types = User.types
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show

    if session[:role] == 'admin'
      @user = User.find(params[:id])
      
    else
      @user = User.find(session[:user_id])
      
    end
    
    @types = User.types
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new
    @types = User.types

	  respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  def restore_account
    @types = User.types		

    @user = @email.user
  end
  
  # GET /users/1/edit
  def edit
    if session[:role] == 'admin'
      @user = User.find(params[:id])
    else
      @user = User.find(session[:user_id])
    end
    @types = User.types
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
    @user.active = true    
    @types = User.types    
    @user.owner_id = session[:owner_id]
    
    respond_to do |format|
      if @user.save
      #session[:user_id] = @user.id
			#session[:name] = @user.name
			#session[:email] = @user.email
      #session[:role] = @user.rol
        format.html { redirect_to users_url, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    
    if session[:role] == "admin"
        @user = User.find(params[:id])
    elsif session[:user_id]
        @user = User.find(session[:user_id])
    else
      @user = User.find(@email.user_id)
    end
    
    @types = User.types
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to users_url, notice: 'User was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find_by_id_and_owner_id(params[:id], session[:owner_id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end

  def change_active

		usr_id=params[:id]
		@user=User.find_by_id_and_owner_id(usr_id, session[:owner_id])

		if @user.active?
			@user.active=false
			act_user = false
		else
			@user.active=true
			act_user = true
		end
		#session[:user_id]=id
		@user.save

		respond_to do |format|
			format.json  { render json: {"act_user" => act_user, "usr_id" => usr_id} }
			format.html
			format.xml { head :ok }
		end
  end
    protected
#	def authorize_admin
#		retval = super
#		if retval != 1
#			if session[:role] != "admin"
#
#				redirect_to url_for(:controller => "application", :action => "index"), :alert => _("User permissions required") and return
#			end
#		end
#	end

end
