# encoding: utf-8
class ClassworksController < ApplicationController
  
  before_filter :login_required
  layout "front"
  
  # GET /classworks
  # GET /classworks.json
  def index
    @current_user.user_accounts.map(&:product_id).uniq.each do |pid|
      product = Product.find_from_cache(pid)
      product.product_classworks.each do |pc|
        if !UserClasswork.exists?(:user_id => @current_user.uid, :classwork_id => pc.classwork_id)
          UserClasswork.create!(:classwork_id => pc.classwork_id, :classwork_name => pc.classwork_name, :product_id => product.id, :product_name => product.name, :user_id => @current_user.uid, :user_name => @current_user.name)
        end
      end unless product.nil?
    end
    @user_classworks = @current_user.user_classworks.order('id DESC').paginate(:page => params[:page], :per_page => GlobalSettings.per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @classworks }
    end
  end

  # GET /classworks/1
  # GET /classworks/1.json
  def show
    @user_classwork = @current_user.user_classworks.find(params[:id])
    @classwork = Classwork.find_from_cache(@user_classwork.classwork_id) if !@user_classwork.nil?
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @classwork }
    end
  end

  # GET /classworks/1/edit
  def edit
    @user_classwork = @current_user.user_classworks.find(params[:id])
    if !@user_classwork.write?
      redirect_to classworks_path, notice: '作业已被锁定，无法修改.' and return
    end
    @classwork = Classwork.find_from_cache(@user_classwork.classwork_id) if !@user_classwork.nil?
  end

  # PATCH/PUT /classworks/1
  # PATCH/PUT /classworks/1.json
  def update
    @user_classwork = @current_user.user_classworks.find(params[:id])
    @user_classwork.transaction do
      @user_classwork.classwork.increment!(:work_num) if !@user_classwork.nil? && @user_classwork.weitijiao?
      upload_hash = FileUploadUtil.uploadFile(params[:answer_file], "classwork", ["zip", "rar", "docx", "doc", "txt"], @user_classwork.answer_file)
      if upload_hash[:status] == 'error'
        respond_to do |format|
          flash[:notice] = upload_hash[:msg]
          format.html { render action: "new" }
          format.json { render json: @user_classwork.errors, status: :unprocessable_entity }
        end
        return
      end
      params[:user_classwork][:answer_file] = @user_classwork.answer_file if upload_hash[:file_name].nil?
      params[:user_classwork][:answer_file] = upload_hash[:file_name] unless upload_hash[:file_name].nil?
      respond_to do |format|
        if @user_classwork.update_attributes(params.require(:user_classwork).permit(:answer_text, :answer_file))
          format.html { redirect_to classworks_path, notice: '作业提交成功.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @user_classwork.errors, status: :unprocessable_entity }
        end
      end
    end
  end

end
