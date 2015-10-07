# encoding: utf-8

class HomeController < ApplicationController
  
  before_filter :login_required
  layout :set_layout_dync
  def index
    @user_accounts = @current_user.user_accounts.order('id DESC').paginate(:page => params[:page], :per_page => 10)
  end
  
  def help
  end
  
  def app
  end
  
  def accounts_index
    @user_accounts = @current_user.user_accounts.order('id DESC').paginate(:page => params[:page], :per_page => 10)
  end
  
  def accounts_show
    @user_account = @current_user.user_accounts.find(params[:id])
    if !@user_account.effective?
      redirect_to accounts_index_path, :notice => "账号已过期" and return
    end
  end
  
  def accounts_assets
    @user_account = @current_user.user_accounts.find(params[:account_id])
    product_tree_ids = nil
    @user_account.product.tree_group_data_array.each do |tree_group_data|
      product_tree_group = ProductTreeGroup.find_from_cache(tree_group_data["id"])
      if product_tree_ids.nil?
        product_tree_ids = product_tree_group.node_knowledge_tree_data.gsub(":[]", "").gsub("\"", "").gsub(":", ",").gsub("[", "").gsub("]", "").gsub("{", "").gsub("}", "") unless product_tree_group.nil?
      else
        product_tree_ids = product_tree_ids + "," + product_tree_group.node_knowledge_tree_data.gsub(":[]", "").gsub("\"", "").gsub(":", ",").gsub("[", "").gsub("]", "").gsub("{", "").gsub("}", "") unless product_tree_group.nil?
      end
    end
    
    
    respond_to do |format|
      format.mobile {
        if !product_tree_ids.nil?
          product_tree_ids = eval("["+product_tree_ids+"]")
          @assets = GlobalAsset.where("assetable_type = 'ProductTree' and assetable_id in ("+product_tree_ids.uniq.join(",")+")").paginate(:page => params[:page], :per_page => 10)
        end
      }
      format.html {
        if !product_tree_ids.nil?
          product_tree_ids = eval("["+product_tree_ids+"]")
          @assets = GlobalAsset.where("assetable_type = 'ProductTree' and assetable_id in ("+product_tree_ids.uniq.join(",")+")").paginate(:page => params[:page], :per_page => 10)
        end
      }
      format.json {
        if !product_tree_ids.nil?
          product_tree_ids = eval("["+product_tree_ids+"]")
          @assets = GlobalAsset.where("assetable_type = 'ProductTree' and assetable_id in ("+product_tree_ids.uniq.join(",")+")")
          render :json => @assets.as_json(:only => [:id, :assetable_id, :data_file_name])
        end
      }
    end
  end
  
  def accounts_assets_down
    @asset = GlobalAsset.find(params[:asset_id])
    @user_account = @current_user.user_accounts.find(params[:account_id])
    product_tree_ids = nil
    @user_account.product.tree_group_data_array.each do |tree_group_data|
	        product_tree_group = ProductTreeGroup.find_from_cache(tree_group_data["id"])
      if product_tree_ids.nil?

        product_tree_ids = product_tree_group.node_knowledge_tree_data.gsub(":[]", "").gsub("\"", "").gsub(":", ",").gsub("[", "").gsub("]", "").gsub("{", "").gsub("}", "")
      else
        product_tree_ids = product_tree_ids + "," + product_tree_group.node_knowledge_tree_data.gsub(":[]", "").gsub("\"", "").gsub(":", ",").gsub("[", "").gsub("]", "").gsub("{", "").gsub("}", "")
      end
    end
    
    file_full_path = '/x-accel-redirect-down/not_exist.txt'
    file_name = @asset.data_file_name
    if !product_tree_ids.nil?
      product_tree_ids = eval("["+product_tree_ids+"]")
      if GlobalAsset.exists?(["id = ? and assetable_type = 'ProductTree' and assetable_id in ("+product_tree_ids.uniq.join(",")+")", params[:asset_id]])
        file_full_path = '/x-accel-redirect-down' + @asset.data_file_url
      end
    end
    
    response.headers['X-Accel-Redirect'] = file_full_path  
    response.headers['Content-Type'] = 'application/octet-stream'
    response.headers['X-Accel-Charset'] = 'utf-8'
    response.headers['Content-Disposition'] = 'attachment; filename=' + file_name + file_full_path[file_full_path.rindex(".")...file_full_path.length]

    render :nothing => true
  end
  
  def user_profile
    
  end
  
  def update_user_profile
    
    if !params[:avatar].nil? && params[:avatar].size > 0
      if params[:avatar].size >= 1024000
        respond_to do |format|
          flash[:notice] = "头像大小不能超过1M!"
          format.mobile { render action: "user_profile" and return }
          format.html { render action: "user_profile" and return }
          format.json { render :json => {"status" => "error", "msg" => "头像大小不能超过1M!"} and return }
        end
      end
    end
    
    upload_hash = FileUploadUtil.uploadImage(params[:avatar],"user")
    
    if upload_hash[:status] == 'error'
      respond_to do |format|
        flash[:notice] = upload_hash[:msg]
        format.mobile { render action: "user_profile" and return }
        format.html { render action: "user_profile" and return }
        format.json { render :json => {"status" => "error", "msg" => "#{upload_hash[:msg]}"} and return }
      end
    end
    params[:user][:avatar_path] = upload_hash[:file_name] unless params[:avatar].nil?
    params[:user][:avatar_path] = @current_user.avatar_path if params[:avatar].nil?
    
    if params[:user][:email] != @current_user.email
      result = Net::HTTP.get(GlobalSettings.login_host, "/update_email.json?id=#{@current_user.uid}&email=#{params[:user][:email]}&key=" + Digest::MD5.hexdigest(@current_user.uid.to_s + params[:user][:email] + @current_user.salt), GlobalSettings.login_port).force_encoding('UTF-8')
    end
    if !result.nil?
      result = eval(result.gsub(":", "=>"))
      if result["status"] == "error"
        respond_to do |format|
          flash[:notice] = upload_hash[:msg]
          format.mobile { render action: "user_profile" and return }
          format.html { render action: "user_profile" and return }
          format.json { render :json => result and return }
        end
      end
    end
    
    if @current_user.update_attributes(params.require(:user).permit(:full_name, :gender, :mobile_phone, :address, :email, :avatar_path))
      respond_to do |format|
        format.mobile { redirect_to user_profile_path, :notice => "个人信息修改成功!"}
        format.html { redirect_to user_profile_path, :notice => "个人信息修改成功!"}
        format.json { render :json => {"status" => "success", "msg" => "个人信息修改成功!"} }
      end
    else
      respond_to do |format|
        format.mobile { redirect_to user_profile_path, :notice => "系统错误!" }
        format.html { redirect_to user_profile_path, :notice => "系统错误!" }
        format.json { render :json => {"status" => "error", "msg" => "系统错误!"} }
      end
    end
  end
  
  def user_password
    
  end
  
  def update_user_password
    if params[:user][:password].length < 6
      render :json => {"status" => "error", "msg" => "新密码不能少于6位!"} and return
    end
    result = Net::HTTP.get(GlobalSettings.login_host, "/update_password.json?id=#{@current_user.uid}&current_password=#{params[:user][:current_password]}&password=#{params[:user][:password]}&key=" + Digest::MD5.hexdigest(@current_user.uid.to_s + params[:user][:current_password] + params[:user][:password] + @current_user.salt), GlobalSettings.login_port).force_encoding('UTF-8')
    if result.nil?
      render :json => {"status" => "error", "msg" => "系统错误!"} and return
    end
    result = eval(result.gsub(":", "=>"))
    render :json => result and return
  end
  
  def knowledge_index
    @user_account = @current_user.user_accounts.find(params[:account_id])
    
    @user_account.product.tree_group_data_array.each do |tgd|
      if tgd['id'] == params[:tgd_id].to_i
        @product_tree_group = ProductTreeGroup.find(tgd['id'])
      end
    end
    
    if @product_tree_group.nil?
      redirect_to "/404.html" and return
    end

    if !@product_tree_group.node_knowledge_tree_data_hash.has_key?(params[:pt_id])
      redirect_to "/404.html" and return
    end

    @product_tree = ProductTree.find_from_cache(params[:pt_id])
    if @product_tree.nil?
      redirect_to "/404.html" and return
    end
    @knowledge_trees = @product_tree_group.node_knowledge_tree_data_hash[params[:pt_id]]
  end
  
  def knowledge_listen
    @user_account = @current_user.user_accounts.find(params[:account_id])
    
    @user_account.product.tree_group_data_array.each do |tgd|
      if tgd['id'] == params[:tgd_id].to_i
        @product_tree_group = ProductTreeGroup.find(tgd['id'])
      end
    end
    
    if @product_tree_group.nil?
      redirect_to "/404.html" and return
    end

    if !@product_tree_group.node_knowledge_tree_data_hash.has_key?(params[:pt_id])
      redirect_to "/404.html" and return
    end

    @product_tree = ProductTree.find_from_cache(params[:pt_id])
    @knowledge_trees = @product_tree_group.node_knowledge_tree_data_hash[params[:pt_id]]
    
    if !@knowledge_trees.include?(params[:kt_id].to_i)
      redirect_to "/404.html" and return
    end
    @knowledge_tree = KnowledgeTree.find_from_cache(params[:kt_id])
    
    @note = @current_user.notes.where("account_id = ? and knowledge_tree_id = ?", params[:account_id].to_i, params[:kt_id].to_i).first || Note.new(:account_id => params[:account_id], :product_tree_id => params[:pt_id], :knowledge_tree_id => params[:kt_id])
  end
  
  def update_note
    @note = @current_user.notes.where("account_id = ? and knowledge_tree_id = ?", params[:note][:account_id].to_i, params[:note][:knowledge_tree_id].to_i).first
    if @note.nil?
      @user_account = @current_user.user_accounts.find(params[:note][:account_id])
      @user_account.transaction do
        @user_account.update_attribute(:note, true) unless @user_account.note 
        
        @note = Note.new params.require(:note).permit(:account_id, :content, :product_tree_id, :knowledge_tree_id)
        @note.product = @user_account.product
        @note.product_name = @user_account.product.name
        @knowledge_tree = KnowledgeTree.find_from_cache(params[:note][:knowledge_tree_id])
        @note.knowledge_tree_name = @knowledge_tree.name
        @note.user = @current_user
        @note.user_name = @current_user.name
        if @note.save
          render json: {"status"  =>  "success", "msg"  => "笔记保存成功!"}
        else
          render json: {"status"  =>  "error", "msg"  => "笔记保存失败!"}
        end
      end
    else
      if @note.update_attributes(params.require(:note).permit(:content))
        render json: {"status"  =>  "success", "msg"  => "笔记保存成功!"}
      else
        render json: {"status"  =>  "error", "msg"  => "笔记保存失败!"}
      end
    end
  end
  
  def notes_index
    @user_accounts = @current_user.user_accounts.where("note = ?", true).paginate(:page => params[:page], :per_page => 10)
  end
  
  def notes_show
    @user_account = @current_user.user_accounts.find(params[:account_id])
    @notes = @current_user.notes.where("account_id = ?", params[:account_id]).paginate(:page => params[:page], :per_page => 10)
  end
  
  def notes_down
    @note = @current_user.notes.find(params[:id])
    content = <<END_OF_NOTE
      ======#{@note.knowledge_tree_name}======#{@note.created_at.strftime("%Y-%m-%d %H:%M:%S")}
      #{@note.content}
END_OF_NOTE
    send_data content, :filename => @note.product_name + "-" + @note.knowledge_tree_name + ".txt", :type => 'application/octet-stream'
  end
  
  def notes_destroy
    @note = @current_user.notes.find(params[:id])
    @note.transaction do
      @note.destroy
      @current_user.user_accounts.find(@note.account_id).update_attribute(:note, false) if @current_user.notes.where("account_id = ?", @note.account_id).count == 0
    end
    respond_to do |format|
      format.html { redirect_to user_notes_show_path(:account_id => @note.account_id), :notice => "笔记删除成功!" }
      format.json { head :no_content }
    end
  end
  
  def account_notes_down
    @user_account = @current_user.user_accounts.find(params[:account_id])
    @notes = @current_user.notes.where("account_id = ?", params[:account_id]).order("id ASC")
    contents = ''
    @notes.each do |note|
      contents = contents + <<END_OF_NOTE
      ======#{note.knowledge_tree_name}======#{note.created_at.strftime("%Y-%m-%d %H:%M:%S")}
      #{note.content}
  
  
END_OF_NOTE
    end
    send_data contents, :filename => @user_account.product_name + ".txt", :type => 'application/octet-stream'
  end
  
  
  def money_records
    @record_type = params[:record_type].nil? ? 1 : 2
    @money_records = @current_user.user_money_records.where("record_type = ?", @record_type).paginate(:page => params[:page], :per_page => 10).order("id DESC")
  end
  
  def recharges_index
    @user_money_record = UserMoneyRecord.new :record_type => 1
  end
  
  def recharges_create
    amount = params[:user_money_record][:amount]
    if (/^(([1-9]\d*)|0)(\.\d{1,2})?$/ =~ amount).nil?
      render json: {"status"  =>  "error", "msg"  => "金额格式不正确!"} and return
    end
    if amount == "0" || amount == "0.0" || amount == "0.00"
      render json: {"status"  =>  "error", "msg"  => "金额格式不正确!"} and return
    end
    if !Order.pay_code_hash.has_key?(params[:user_money_record][:pay_code])
      render json: {"status"  =>  "error", "msg"  => "支付方式不正确!"} and return
    end
    @user_money_record = UserMoneyRecord.new :pay_type => 10, :pay_code => params[:user_money_record][:pay_code], :user_id => @current_user.uid, :user_name => @current_user.name, :status => 1, :record_type => 1, :amount => params[:user_money_record][:amount]
   if @user_money_record.save
     render json: {"status"  =>  "success", "msg"  => "充值记录创建成功!", "recharge_id" => @user_money_record.id}
   else
     render json: {"status"  =>  "error", "msg"  => "充值记录创建失败!"}
   end
  end
  
  def recharges_pay
    @recharge = @current_user.user_money_records.find(params[:id])
    if @recharge.zhifubao? && @recharge.weifukuan? && @recharge.amount > 0 && !session[:mobile_view]
      @pay_str = Net::HTTP.get(GlobalSettings.pay_host, "/alipay/alipayapi.jsp?WIDout_trade_no=recharge_#{@recharge.id}&WIDout_total_fee=#{@recharge.amount}&WIDout_defaultbank=#{@recharge.pay_code}", GlobalSettings.pay_port).force_encoding('UTF-8')
    end
    if @recharge.zhifubao? && @recharge.weifukuan? && @recharge.amount > 0 && session[:mobile_view]
      @pay_str = Net::HTTP.get(GlobalSettings.pay_host, "/alipay/wapalipayapi.jsp?WIDout_trade_no=recharge_#{@recharge.id}&WIDtotal_fee=#{@recharge.amount}&WIDout_defaultbank=#{@recharge.pay_code}", GlobalSettings.pay_port).force_encoding('UTF-8')
    end
    if @recharge.kuaiqian? && @recharge.weifukuan? && @recharge.amount > 0
      @pay_str = Net::HTTP.get(GlobalSettings.pay_host, "/99bill/send.jsp?orderId=recharge_#{@recharge.id}&orderAmount=#{@recharge.amount*100}&orderTime=#{@recharge.created_at.strftime("%Y%m%d%H%M%S")}&payType=#{@recharge.pay_type}&bankId=#{@recharge.pay_code}&email=#{@current_user.email}", GlobalSettings.pay_port).force_encoding('UTF-8')
    end
    render :layout => false
  end
  
  def messages_system
    
    user_message = UserMessageCount.where(:user_id => @current_user.uid).first
    if !user_message.nil?
      user_message.system_count = 0
      user_message.updated_at = DateTime.now
      user_message.save
    end
    
    pre_page = 20
    @page = params[:page].nil? ? 1 : params[:page].to_i
    from_to = (@page-1) * pre_page
    #@system_messages = Net::HTTP.get(GlobalSettings.message_domain, "/messages/system?user_id=#{@current_user.uid}&created_at=#{@current_user.created_at.to_f}&page=#{@page}", GlobalSettings.message_port).force_encoding('UTF-8')
    #@system_messages = eval(@system_messages.gsub(":", "=>"))
    @system_messages = SystemMessage.where(:type => 1, "$or" => [{:user_id => 0}, {:user_id => @current_user.uid}]).sort(:created_at => -1).skip(from_to).limit(pre_page)
    
    @system_messages_count = SystemMessage.where(:type => 1, "$or" => [{:user_id => 0}, {:user_id => @current_user.uid}]).count
    @system_messages_count = @system_messages_count % pre_page == 0 ? @system_messages_count/pre_page : @system_messages_count/pre_page + 1
    
  end
  
  def messages_study
    user_message = UserMessageCount.where(:user_id => @current_user.uid).first
    if !user_message.nil?
      user_message.study_count = 0
      user_message.updated_at = DateTime.now
      user_message.save
    end
    #@page = params[:page].nil? ? 1 : params[:page].to_i
    #@system_messages = Net::HTTP.get(GlobalSettings.message_domain, "/messages/study?user_id=#{@current_user.uid}&page=#{@page}", GlobalSettings.message_port).force_encoding('UTF-8')
    #@system_messages = eval(@system_messages.gsub(":", "=>"))
    pre_page = 20
    @page = params[:page].nil? ? 1 : params[:page].to_i
    from_to = (@page-1) * pre_page
    @system_messages = SystemMessage.where(:type => 2, "$or" => [{:user_id => 0}, {:user_id => @current_user.uid}]).sort(:created_at => -1).skip(from_to).limit(pre_page)
    @system_messages_count = SystemMessage.where(:type => 2, "$or" => [{:user_id => 0}, {:user_id => @current_user.uid}]).count
    @system_messages_count = @system_messages_count % pre_page == 0 ? @system_messages_count/pre_page : @system_messages_count/pre_page + 1
    
  end
  
  def messages_private
    user_message = UserMessageCount.where(:user_id => @current_user.uid).first
    if !user_message.nil?
      user_message.private_count = 0
      user_message.updated_at = DateTime.now
      user_message.save
    end
    pre_page = 20
    @page = params[:page].nil? ? 1 : params[:page].to_i
    from_to = (@page-1) * pre_page
    @system_messages = MessageGroup.where(:user_ids.in => [@current_user.uid],"$or" => [{:user_id_1 => @current_user.uid}, {:user_id_2 => @current_user.uid}]).sort(:created_at => -1).skip(from_to).limit(pre_page)
    @system_messages_count = MessageGroup.where(:user_ids.in => [@current_user.uid],"$or" => [{:user_id_1 => @current_user.uid}, {:user_id_2 => @current_user.uid}]).count
    @system_messages_count = @system_messages_count % pre_page == 0 ? @system_messages_count/pre_page : @system_messages_count/pre_page + 1
  end
  
  def messages_count
    user_message = UserMessageCount.where(:user_id => @current_user.uid).first
    if user_message.nil?
      render :json => {"private_message_count" => 0, "system_message_count" => 0, "study_message_count" => 0}.to_json and return
    else
      render :json => {"private_message_count" => user_message.private_count, "system_message_count" => user_message.system_count, "study_message_count" => user_message.study_count}.to_json and return
    end
  end
  
  def messages_private_show
    pre_page = 20
    @page = params[:page].nil? ? 1 : params[:page].to_i
    from_to = (@page-1) * pre_page
    @system_messages = Message.where(:user_ids.in => [@current_user.uid],"$or" => [{:send_id => @current_user.uid, :receive_id => params[:id].to_i}, {:send_id => params[:id].to_i, :receive_id => @current_user.uid}]).sort(:created_at => -1).skip(from_to).limit(pre_page)
    @system_messages_count = Message.where(:user_ids.in => [@current_user.uid],"$or" => [{:send_id => @current_user.uid, :receive_id => params[:id].to_i}, {:send_id => params[:id].to_i, :receive_id => @current_user.uid}]).count
    @system_messages_count = @system_messages_count % pre_page == 0 ? @system_messages_count/pre_page : @system_messages_count/pre_page + 1
  end
  
  def messages_private_destroy
    @message_group = MessageGroup.find(params[:id])
    if @message_group.user_id_1 == @current_user.uid || @message_group.user_id_2 == @current_user.uid
      @message_group.user_ids.delete(@current_user.uid)
      @message_group.user_id_1 == @current_user.uid ? (@message_group.message_count_1 = 0) : (@message_group.message_count_2 = 0)
      if @message_group.user_ids.empty?
        @message_group.delete
        Message.where("$or" => [{:send_id => @message_group.user_id_1, :receive_id => @message_group.user_id_2}, {:send_id => @message_group.user_id_2, :receive_id => @message_group.user_id_2}]).delete
      else
        @message_group.save
        Message.where("$or" => [{:send_id => @message_group.user_id_1, :receive_id => @message_group.user_id_2}, {:send_id => @message_group.user_id_2, :receive_id => @message_group.user_id_2}]).update(:user_ids => @message_group.user_ids)
      end
     
    end
    redirect_to user_messages_private_path
  end
  
  def messages_private_create
    _content = params[:content]
    if _content.nil? || _content.blank?
      render :json => {"status" => "error", "msg" => "私信内容不能为空!"}.to_json and return
    end
    if _content.length > 300
      render :json => {"status" => "error", "msg" => "私信内容不能超过300个字符!"}.to_json and return
    end
    receive_user = User.find(params[:receive_id]) unless params[:receive_id].nil?
    receive_user = User.where("name = ?", params[:receive_user_name]).first unless params[:receive_user_name].nil?
    if receive_user.nil?
      render :json => {"status" => "error", "msg" => "发送的用户不存在!"}.to_json and return
    end
    if receive_user.uid == @current_user.uid
      render :json => {"status" => "error", "msg" => "不能将私信发给自己!"}.to_json and return
    end
    date_now = DateTime.now
    message = Message.new
    message.send_id = @current_user.uid
    message.send_user_name = @current_user.name
    message.send_status = 1
    message.receive_id = receive_user.uid
    message.receive_user_name = receive_user.name
    message.receive_status = 1
    message.content = _content
    message.user_ids = [@current_user.uid, receive_user.uid]
    message.created_at = date_now
    if message.save
      user_id_1 = @current_user.uid > receive_user.uid ? receive_user.uid : @current_user.uid
      user_id_2 = @current_user.uid > receive_user.uid ? @current_user.uid : receive_user.uid
      message_group = MessageGroup.where(:user_id_1 => user_id_1, :user_id_2 => user_id_2).first
      if message_group.nil?
        message_group = MessageGroup.new
        message_group.user_id_1 = user_id_1
        message_group.user_name_1 = (user_id_1 == @current_user.uid ? @current_user.name : receive_user.name)
        message_group.user_id_2 = user_id_2
        message_group.user_name_2 = (user_id_2 == @current_user.uid ? @current_user.name : receive_user.name)
        message_group.last_msg_1 = message.to_hash
        message_group.last_msg_2 = message.to_hash
        message_group.unread_count_1 = (user_id_1 == @current_user.uid ? 0 : 1)
        message_group.unread_count_2 = (user_id_2 == @current_user.uid ? 0 : 1)
        message_group.message_count_1 = 1
        message_group.message_count_2 = 1
        message_group.created_at = date_now
        message_group.updated_at = date_now
        message_group.user_ids = [@current_user.uid, receive_user.uid]
        message_group.save
      else
        if user_id_1 == @current_user.uid
          message_group.last_msg_1 = message.to_hash
          message_group.last_msg_2 = message.to_hash
          message_group.updated_at = date_now
          message_group.inc(:message_count_1, 1)
          message_group.inc(:message_count_2, 1)
          message_group.inc(:unread_count_2, 1)
          message_group.user_ids = [@current_user.uid, receive_user.uid]
          message_group.save
        else
          message_group.last_msg_1 = message.to_hash
          message_group.last_msg_2 = message.to_hash
          message_group.updated_at = date_now
          message_group.inc(:message_count_1, 1)
          message_group.inc(:message_count_2, 1)
          message_group.inc(:unread_count_1, 1)
          message_group.user_ids = [@current_user.uid, receive_user.uid]
          message_group.save
          
        end
        
      end
      UserMessageCount.inc_private_message(receive_user.uid)
      render :json => {"status" => "success", "msg" => "私信发送成功!"}.to_json and return
    else
      render :json => {"status" => "error", "msg" => "系统错误!"}.to_json and return
    end
  end
  
  def learn_schedule_update
    @user_account = @current_user.user_accounts.find(params[:account_id])
    learn_schedule = LearnSchedule.where(:user_id => @current_user.uid, :account_id => params[:account_id]).first
    if learn_schedule.nil?
      learn_schedule = LearnSchedule.new
      learn_schedule.user_id = @current_user.uid
      learn_schedule.user_name = @current_user.name
      learn_schedule.account_id = @user_account.id
      learn_schedule.product_id = @user_account.product.id
      learn_schedule.product_name = @user_account.product.name
      learn_schedule.knowledge_id = params[:knowledge_id]
      knowledge_tree = KnowledgeTree.find_from_cache(params[:knowledge_id])
      learn_schedule.knowledge_name = knowledge_tree.name
      learn_schedule.knowledge_schedule = {}
      learn_schedule.created_at = DateTime.now
      learn_schedule.updated_at = DateTime.now
    end
    if learn_schedule.knowledge_schedule[params[:knowledge_id].to_i].nil?
      learn_schedule.knowledge_schedule[params[:knowledge_id].to_i] = params[:second].to_f
    else
      if params[:second].to_f > learn_schedule.knowledge_schedule[params[:knowledge_id].to_i]
        learn_schedule.knowledge_schedule[params[:knowledge_id].to_i] = params[:second].to_f
      end
    end
    
    learn_schedule.save
    render :text => "success"
  end
  
  def questions
      @page = params[:page].nil? ? 1 : params[:page].to_i
      @question_objs = Net::HTTP.get(GlobalSettings.ask_host, "/question/myindex.action?userId=#{@current_user.uid}&pageNo=#{@page}", GlobalSettings.ask_port).force_encoding('UTF-8')
      @question_objs = eval(@question_objs.gsub(":","=>"))
    end
  
end
