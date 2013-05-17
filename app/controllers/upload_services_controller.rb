class UploadServicesController < ApplicationController
  # GET /upload_services
  # GET /upload_services.json

  respond_to :html, :xml, :json, :iframe

  def index
    @upload_services = UploadService.find_all_by_owner_id(session[:owner_id])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @upload_services }
    end
  end

  # GET /upload_services/1
  # GET /upload_services/1.json
  def show
    @upload_service = UploadService.find_by_id_and_owner_id(params[:id],session[:owner_id])
    if @upload_service
      respond_to do |format|
		  format.iframe { render self.to_iframe}
        format.html # show.html.erb
        format.json { render json: @upload_service }
      end
    else
       redirect_to upload_services_url
    end
  end

  # GET /upload_services/new
  # GET /upload_services/new.json
  def new
    @upload_service = UploadService.new
    @upload_service.meta = Hash.new
    @posible_locations = Array.new
    @posible_locations.push('Select One')
    @posible_locations.push('AmazonS3')
    @posible_locations.push('FTP')
    @location
    
    respond_to do |format|
      format.iframe { render self.to_iframe }
      format.html # new.html.erb
      format.json { render json: @upload_service }
    end
  end

  # GET /upload_services/1/edit
  def edit
    @upload_service = UploadService.find_by_id_and_owner_id(params[:id],session[:owner_id])
    if @upload_service
      @posible_locations = Array.new
      @posible_locations.push('Select One')
      @posible_locations.push('AmazonS3')
      @posible_locations.push('FTP')
      @location = @upload_service.location
    else
      redirect_to upload_services_url
    end
  end

  # POST /upload_services
  # POST /upload_services.json
  def create
    @upload_service = UploadService.new(params[:upload_service])
    @posible_locations = Array.new
    @posible_locations.push('Select One')
    @posible_locations.push('AmazonS3')
    @posible_locations.push('FTP')
    @location = @upload_service.location
    if @upload_service.location == 'Select One'
      @upload_service.location = nil
    elsif @upload_service.location == 'FTP'
      @upload_service.meta = params[:FTP]
    elsif @upload_service.location == 'AmazonS3'
      @upload_service.meta = params[:AmazonS3]
    end
    @upload_service.owner_id = session[:owner_id]
    respond_to do |format|
      if @upload_service.save
        format.iframe { render json: @upload_service, status: :created, location: @upload_service}
        format.html { redirect_to @upload_service, notice: 'Upload service was successfully created.' }
        format.json { render json: @upload_service, status: :created, location: @upload_service }
      else
        format.html { render action: "new" }
        format.json { render json: @upload_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /upload_services/1
  # PUT /upload_services/1.json
  def update
    @upload_service = UploadService.find_by_id_and_owner_id(params[:id],session[:owner_id])
    @posible_locations = Array.new
    @posible_locations.push('Select One')
    @posible_locations.push('AmazonS3')
    @posible_locations.push('FTP')
      @location = @upload_service.location

    if params[:upload_service][:location] == 'Select One'
      @upload_service.location = nil
    elsif params[:upload_service][:location] == 'FTP'
      @upload_service.meta = params[:FTP]
    elsif params[:upload_service][:location] == 'AmazonS3'
      @upload_service.meta = params[:AmazonS3]
    end
    respond_to do |format|
      if  @upload_service.update_attributes(params[:upload_service])
        format.html { redirect_to @upload_service, notice: 'Upload service was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @upload_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /upload_services/1
  # DELETE /upload_services/1.json
  def destroy
    @upload_service = UploadService.find_by_id_and_owner_id(params[:id],session[:owner_id])
    if @upload_service
      @upload_service.destroy

      respond_to do |format|
        format.html { redirect_to upload_services_url }
        format.json { head :no_content }
      end
    else
      redirect_to upload_services_url
    end
  end

  def to_iframe
		@nobuttons = true
		return :action => params[:action]+".html", :layout => "no_layout"
	end


end
