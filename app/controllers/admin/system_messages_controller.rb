# encoding: utf-8

class Admin::SystemMessagesController < ApplicationController
  
  before_filter :login_required
  load_and_authorize_resource
  before_filter :init_breadcrumb_and_module_name
  layout "admin"
  
  # GET /notes
  # GET /notes.json
  def index
    @system_message = SystemMessage.new params.require(:system_message).permit(:type) unless params[:system_message].nil?
    @system_message = SystemMessage.new if params[:system_message].nil?
    @page = params[:page].nil? ? 1 : params[:page].to_i
    from_to = (@page-1) * GlobalSettings.per_page
    @system_messages = SystemMessage.where(:type => 1) if @system_message.type.nil?
    @system_messages = SystemMessage.where(:type => @system_message.type) unless @system_message.type.nil?
    @system_messages = @system_messages.skip(from_to).limit(GlobalSettings.per_page).sort(:created_at => -1)
    @system_messages_count = SystemMessage.where(:type => 1).count
    @system_messages_count = @system_messages_count % GlobalSettings.per_page == 0 ? @system_messages_count/GlobalSettings.per_page : @system_messages_count/GlobalSettings.per_page + 1
    
  end
  
  def new
    @system_message = SystemMessage.new
  end
  
  def edit
    @system_message = SystemMessage.where(:id => params[:id]).first
  end
  
  def update
    @system_message = SystemMessage.where(:id => params[:id]).first
    if @system_message.update_attributes(params.require(:system_message).permit(:user_id, :user_name, :content))
      redirect_to admin_system_message_path(@system_message), notice: '系统消息修改成功.'
    else
      render action: "edit"
    end
  end
  
  def create
    @system_message = SystemMessage.new params.require(:system_message).permit(:user_id, :user_name, :content)
    @system_message.admin_user_id = @current_user.uid
    @system_message.admin_user_name = @current_user.name
    @system_message.type = 1
    @system_message.user_id = 0 if @system_message.user_id.nil?
    @system_message.user_name = '' if @system_message.user_name.nil?
    @system_message.created_at = DateTime.now
    if @system_message.save
      if @system_message.user_id == 0
        User.select("uid").all.each do |user|
          UserMessageCount.inc_system_message(user.uid)
        end
      end
      UserMessageCount.inc_system_message(@system_message.user_id) if @system_message.user_id > 0
      redirect_to admin_system_message_path(@system_message), notice: '系统消息新建成功.'
    else
      render action: "new"
    end
  end

  # GET /notes/1
  # GET /notes/1.json
  def show
    @system_message = SystemMessage.where(:_id => params[:id]).first
    drop_breadcrumb(@system_message._id, admin_system_message_path(@system_message))
  end
  
  def destroy
    @system_message = SystemMessage.find(params[:id])
    @system_message.destroy
    redirect_to admin_system_messages_path, notice: '消息删除成功.'
  end

  private
    
    def init_breadcrumb_and_module_name
      drop_breadcrumb("系统消息", admin_system_messages_path)
      @_module_name = 'system_message'
      @__module_name = 'SystemMessage'
      @_module_new = false
      @_module_edit = false
      @_module_delete = false
    end
end