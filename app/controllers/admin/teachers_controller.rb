# encoding: utf-8

class Admin::TeachersController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource
  before_filter :init_breadcrumb_and_module_name
  layout "admin"
  
  # GET /admin/teachers
  # GET /admin/teachers.json
  def index
    respond_to do |format|
      format.html {
        @search = Teacher.search(params[:search])
        @teachers = @search.paginate(:page => params[:page], :per_page => GlobalSettings.per_page).order('id DESC')
      }
      format.json {
        render json: Teacher.select("id, name as text").to_json
      }
    end
  end

  # GET /admin/teachers/1
  # GET /admin/teachers/1.json
  def show
    @teacher = Teacher.find(params[:id])

    drop_breadcrumb(@teacher.name, admin_teacher_path(@teacher))
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @teacher }
    end
  end

  # GET /admin/teachers/new
  # GET /admin/teachers/new.json
  def new
    @teacher = Teacher.new
    
    drop_breadcrumb('新增')
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @teacher }
    end
  end

  # GET /admin/teachers/1/edit
  def edit
    @teacher = Teacher.find(params[:id])
    
    drop_breadcrumb(@teacher.name, admin_teacher_path(@teacher))
    drop_breadcrumb('修改')
  end

  # POST /admin/teachers
  # POST /admin/teachers.json
  def create
    @teacher = Teacher.new teacher_params
    upload_hash = FileUploadUtil.uploadImage(params[:img_path_file],"teacher")
    if upload_hash[:status] == 'error'
      respond_to do |format|
        flash[:notice] = upload_hash[:msg]
        format.html { render action: "new" }
        format.json { render json: @teacher.errors, status: :unprocessable_entity }
      end
      return;
    end
    @teacher.img_path = upload_hash[:file_name] unless params[:img_path_file].nil?
    
    respond_to do |format|
      if @teacher.save
        format.html { redirect_to admin_teacher_path(@teacher), notice: '老师新建成功.' }
        format.json { render json: @teacher, status: :created, location: @teacher }
      else
        format.html { render action: "new" }
        format.json { render json: @teacher.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/teachers/1
  # PATCH/PUT /admin/teachers/1.json
  def update
    @teacher = Teacher.find(params[:id])
    
    upload_hash = FileUploadUtil.uploadImage(params[:img_path_file], "teacher", @teacher.img_path)
    if upload_hash[:status] == 'error'
      respond_to do |format|
        flash[:notice] = upload_hash[:msg]
        format.html { render action: "new" }
        format.json { render json: @teacher.errors, status: :unprocessable_entity }
      end
      return;
    end
    @teacher.img_path = upload_hash[:file_name] unless params[:img_path_file].nil?
    
    respond_to do |format|
      if @teacher.update_attributes(teacher_params)
        format.html { redirect_to admin_teacher_path(@teacher), notice: '老师修改成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @teacher.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/teachers/1
  # DELETE /admin/teachers/1.json
  def destroy
    @teacher = Teacher.find(params[:id])
    @teacher.destroy

    respond_to do |format|
      format.html { redirect_to admin_teachers_path }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def teacher_params
      params.require(:teacher).permit(:name, :description, :recommend, :subject_first, :subject_second, :ttype, :code, :deleted, :sortrank)
    end

    def teacher_params_update
      params.require(:teacher).permit(:name, :description, :recommend, :subject_first, :subject_second, :ttype, :deleted, :sortrank)
    end
    
    def init_breadcrumb_and_module_name
      drop_breadcrumb("老师", admin_teachers_path)
      @_module_name = 'teacher'
      @__module_name = 'Teacher'
    end
end
