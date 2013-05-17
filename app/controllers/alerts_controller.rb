class AlertsController < ApplicationController
  # GET /alerts
  # GET /alerts.json
  def index
    @alerts = Alert.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @alerts }
    end
  end

  # GET /alerts/1
  # GET /alerts/1.json
  def show
    @alert = Alert.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @alert }
    end
  end

  # GET /alerts/new
  # GET /alerts/new.json
  def new
    @alert = Alert.new
    

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @alert }
    end
  end

  # GET /alerts/1/edit
  def edit
    
    # Buscamos si existe un Alert para este owner
    @alert = Alert.find(:first, :conditions => ['owner_id = ?', session[:owner_id]])
    
    if @alert.nil? 
      @alert = Alert.create(:owner_id => session[:owner_id])
    end
    
    # Aquí alert existe
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @alert }
    end 
  end
    

  # POST /alerts
  # POST /alerts.json
  def create
    @alert = Alert.new(params[:alert])

    respond_to do |format|
      if @alert.save
        format.html { redirect_to @alert, notice: 'Alert was successfully created.' }
        format.json { render json: @alert, status: :created, location: @alert }
      else
        format.html { render action: "new" }
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /alerts/1
  # PUT /alerts/1.json
  def update
    @alert = Alert.find(params[:id])
    
    if params[:commit]
    
      @alert.action_alerts.destroy_all
      
      if params[:options]

        params[:options].each do |key|
          action_alert = ActionAlert.new
          action_alert.alert_id = @alert.id
          action_alert.owner_id = @alert.owner_id
          action_alert.action = key 
          action_alert.save
        end

        # Aquí no estarían asociados el Alert con sus ActionAlert, pues los hemos eliminado
        # en el destroy_all. Recargamos desde la BD
        @alert.reload
      end
      
      @alert.update_attributes params[:alert]
      
    end

    respond_to do |format|
      
      format.html { render action: "edit" }
      format.json { render json: @alert.errors, status: :unprocessable_entity }
    
    end
  end

  # DELETE /alerts/1
  # DELETE /alerts/1.json
  def destroy
    @alert = Alert.find(params[:id])
    @alert.destroy

    respond_to do |format|
      format.html { redirect_to alerts_url }
      format.json { head :no_content }
    end
  end

end