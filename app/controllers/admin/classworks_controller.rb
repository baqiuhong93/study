# encoding: utf-8
class Admin::ClassworksController < ApplicationController
  
  before_filter :login_required
  load_and_authorize_resource
  before_filter :init_breadcrumb_and_module_name
  layout "admin"
  
  # GET /classworks
  # GET /classworks.json
  def index
    respond_to do |format|
      format.html {
        @search = Classwork.search(params[:search])
        @classworks = @search.paginate(:page => params[:page], :per_page => GlobalSettings.per_page).order('id DESC')
      }
      format.json { 
        render json: Classwork.select("id, name as text").to_json 
      }
    end
  end

  # GET /classworks/1
  # GET /classworks/1.json
  def show
    @classwork = Classwork.find(params[:id])
    
    drop_breadcrumb(@classwork.name, admin_classwork_path(@classwork))
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @classwork }
    end
  end

  # GET /classworks/new
  # GET /classworks/new.json
  def new
    @classwork = Classwork.new
    
    drop_breadcrumb('新增')
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @classwork }
    end
  end

  # GET /classworks/1/edit
  def edit
    @classwork = Classwork.find(params[:id])
    
    drop_breadcrumb(@classwork.name, admin_classwork_path(@classwork))
    drop_breadcrumb('修改')
  end

  # POST /classworks
  # POST /classworks.json
  def create
    @classwork = Classwork.new(classwork_params)

    respond_to do |format|
      if @classwork.save
        format.html { redirect_to admin_classwork_path(@classwork), notice: '作业项目创建成功.' }
        format.json { render json: @classwork, status: :created, location: @classwork }
      else
        format.html { render action: "new" }
        format.json { render json: @classwork.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /classworks/1
  # PATCH/PUT /classworks/1.json
  def update
    @classwork = Classwork.find(params[:id])

    respond_to do |format|
      if @classwork.update_attributes(classwork_params)
        format.html { redirect_to admin_classwork_path(@classwork), notice: '作业项目修改成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @classwork.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /classworks/1
  # DELETE /classworks/1.json
  def destroy
    @classwork = Classwork.find(params[:id])
    @classwork.update_attributes(:deleted => @classwork.deleted ? false : true)
    #@classwork.destroy

    respond_to do |format|
      format.html { redirect_to admin_classworks_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def classwork_params
      params.require(:classwork).permit(:demand, :end_at, :name, :start_at)
    end
    
    def init_breadcrumb_and_module_name
      drop_breadcrumb("作业项目", admin_classworks_path)
      @_module_name = 'classwork'
      @__module_name = 'Classwork'
    end
end
