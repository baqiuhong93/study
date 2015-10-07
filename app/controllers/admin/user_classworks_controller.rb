# encoding: utf-8
class Admin::UserClassworksController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource
  before_filter :init_breadcrumb_and_module_name
  layout "admin"
  
  # GET /user_classworks
  # GET /user_classworks.json
  def index
    @search = UserClasswork.search(params[:search])
    @user_classworks = @search.paginate(:page => params[:page], :per_page => GlobalSettings.per_page).order('id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_classworks }
    end
  end

  # GET /user_classworks/1
  # GET /user_classworks/1.json
  def show
    @user_classwork = UserClasswork.find(params[:id])
    
    drop_breadcrumb(@user_classwork.classwork_name, admin_user_classwork_path(@user_classwork))
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_classwork }
    end
  end

  # GET /user_classworks/new
  # GET /user_classworks/new.json
  def new
    @user_classwork = UserClasswork.new
    
    drop_breadcrumb('新增')
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_classwork }
    end
  end

  # GET /user_classworks/1/edit
  def edit
    @user_classwork = UserClasswork.find(params[:id])
    @user_classwork.update_attribute(:status, 2)
    drop_breadcrumb(@user_classwork.classwork_name, admin_user_classwork_path(@user_classwork))
    drop_breadcrumb('修改')
  end

  # POST /user_classworks
  # POST /user_classworks.json
  def create
    @user_classwork = UserClasswork.new(user_classwork_params)

    respond_to do |format|
      if @user_classwork.save
        format.html { redirect_to admin_user_classwork_path(@user_classwork), notice: '作业创建成功.' }
        format.json { render json: @user_classwork, status: :created, location: @user_classwork }
      else
        format.html { render action: "new" }
        format.json { render json: @user_classwork.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_classworks/1
  # PATCH/PUT /user_classworks/1.json
  def update
    @user_classwork = UserClasswork.find(params[:id])
    @user_classwork.admin_user_id = @current_user.uid
    @user_classwork.admin_user_name = @current_user.name
    @user_classwork.status = 3
    
    upload_hash = FileUploadUtil.uploadFile(params[:user_classwork][:reply_file], "classwork", ["zip", "rar", "docx"], @user_classwork.answer_file)
    if upload_hash[:status] == 'error'
      respond_to do |format|
        flash[:notice] = upload_hash[:msg]
        format.html { render action: "edit" }
        format.json { render json: @user_classwork.errors, status: :unprocessable_entity }
      end
      return
    end
    @user_classwork.reply_file = upload_hash[:file_name] unless upload_hash[:file_name].nil?
    
    respond_to do |format|
      if @user_classwork.update_attributes(user_classwork_params)
        format.html { redirect_to admin_user_classwork_path(@user_classwork), notice: '作业修改成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_classwork.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_classworks/1
  # DELETE /user_classworks/1.json
  def destroy
    @user_classwork = UserClasswork.find(params[:id])
    @user_classwork.destroy

    respond_to do |format|
      format.html { redirect_to user_classworks_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def user_classwork_params
      params.require(:user_classwork).permit(:reply_text)
    end
    
    def init_breadcrumb_and_module_name
      drop_breadcrumb("作业", admin_user_classworks_path)
      @_module_name = 'user_classwork'
      @__module_name = 'UserClasswork'
      @_module_new = false
    end
end
