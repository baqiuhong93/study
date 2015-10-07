# encoding: utf-8
class Admin::GlobalAssetsController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource
  before_filter :init_breadcrumb_and_module_name
  layout "admin"
  
  # GET /global_assets
  # GET /global_assets.json
  def index
    @global_assets = GlobalAsset.paginate(:page => params[:page], :per_page => GlobalSettings.per_page).order('id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: GlobalAsset.select("id, data_file_name as text").where("assetable_id is NULL").to_json }
    end
  end

  # GET /global_assets/1
  # GET /global_assets/1.json
  def show
    @global_asset = GlobalAsset.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @global_asset }
    end
  end

  # GET /global_assets/new
  # GET /global_assets/new.json
  def new
    @global_asset = GlobalAsset.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @global_asset }
    end
  end

  # GET /global_assets/1/edit
  def edit
    @global_asset = GlobalAsset.find(params[:id])
  end

  # POST /global_assets
  # POST /global_assets.json
  def create
    @global_asset = GlobalAsset.new(global_asset_params)
    
    upload_hash = FileUploadUtil.uploadFile(params[:data_file], "global_asset", ['rar','pdf','word','zip','txt','sql'])
    if upload_hash[:status] == 'error'
      respond_to do |format|
        flash[:notice] = upload_hash[:msg]
        format.html { render action: "new" }
        format.json { render json: @global_asset.errors, status: :unprocessable_entity }
      end
      return
    end
    if !params[:data_file].nil?
      @global_asset.data_file_url = upload_hash[:file_name]
      @global_asset.data_content_type = upload_hash[:content_type]
      @global_asset.data_file_size = upload_hash[:file_size]
      @global_asset.width = upload_hash[:width]
      @global_asset.height = upload_hash[:height]
      @global_asset.user_id = @current_user.uid
      @global_asset.user_name = @current_user.name
    end
    
    respond_to do |format|
      if @global_asset.save
        format.html { redirect_to admin_global_asset_path(@global_asset), notice: 'Global asset was successfully created.' }
        format.json { render json: @global_asset, status: :created, location: @global_asset }
      else
        format.html { render action: "new" }
        format.json { render json: @global_asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /global_assets/1
  # PATCH/PUT /global_assets/1.json
  def update
    @global_asset = GlobalAsset.find(params[:id])
    
    upload_hash = FileUploadUtil.uploadFile(params[:data_file], "global_asset", ['rar','pdf','word','zip','txt','sql'], @global_asset.data_file_url)
    if upload_hash[:status] == 'error'
      respond_to do |format|
        flash[:notice] = upload_hash[:msg]
        format.html { render action: "new" }
        format.json { render json: @global_asset.errors, status: :unprocessable_entity }
      end
      return
    end
    if !params[:data_file].nil?
      @global_asset.data_file_url = upload_hash[:file_name]
      @global_asset.data_content_type = upload_hash[:content_type]
      @global_asset.data_file_size = upload_hash[:file_size]
      @global_asset.width = upload_hash[:width]
      @global_asset.height = upload_hash[:height]
      @global_asset.user_id = @current_user.uid
      @global_asset.user_name = @current_user.name
    end
    
    respond_to do |format|
      if @global_asset.update_attributes(global_asset_params)
        format.html { redirect_to admin_global_asset_path(@global_asset), notice: 'Global asset was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @global_asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /global_assets/1
  # DELETE /global_assets/1.json
  def destroy
    @global_asset = GlobalAsset.find(params[:id])
    @global_asset.destroy

    respond_to do |format|
      format.html { redirect_to admin_global_assets_path }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def global_asset_params
      params.require(:global_asset).permit(:data_file_name)
    end
    
    def init_breadcrumb_and_module_name
      drop_breadcrumb("附件", admin_global_assets_path)
      @_module_name = 'global_asset'
      @__module_name = 'GlobalAsset'
    end
end
