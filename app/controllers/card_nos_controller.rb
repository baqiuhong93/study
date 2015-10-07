# encoding: utf-8

class CardNosController < ApplicationController
  before_filter :login_required
  layout :set_layout_dync
  
  def new
    @card_no = CardNo.new
  end

  def select
    used_card_no = UsedCardNo.find(params[:used_card_no_id])
    
    if used_card_no.user_id != @current_user.uid || !used_card_no.order_id.nil?
      flash[:notice] = "非法操作！"
      redirect_to new_card_no_path and return
    end
    @card = Card.find(used_card_no.card_id)
    @card_no = CardNo.find(used_card_no.card_no_id)
  end

  def create
    @card_no = CardNo.new card_no_params
    #if captcha_valid? params[:captcha]
      code = params[:card_no][:code]
      if code.nil? || code.split("#").length != 2
        flash[:notice] = "输入不正确！"
        render "new" and return
      end
      @card = Card.where("id = ?", code.split("#")[0].to_i).first
      
      if @card.nil?
        flash[:notice] = "卡不存在！"
        render "new" and return
      end
      
      if !@card.online?
        flash[:notice] = "卡没有上线！"
        render "new" and return
      end
      
      if @card.expired?
        flash[:notice] = "卡已经过期！"
        render "new" and return
      end
      
      @card_no = CardNo.where("code = ?", code).first
      
      if @card_no.nil?
        @card_no = CardNo.new()
        flash[:notice] = "卡号不存在！"
        render "new" and return
      end
      
      if !@card_no.effective?
        @card_no = CardNo.new(:code => @card_no.code)
        flash[:notice] = "卡号无效或已被使用！"
        render "new" and return
      end
      
      if @card_no.passwd != params[:card_no][:passwd]
        @card_no = CardNo.new(:code => @card_no.code)
        flash[:notice] = "密码不正确！"
        render "new" and return
      end
      
      used_card_no = UsedCardNo.where("user_id = ? and card_no_code = ?", @current_user.uid, code).first
      if used_card_no.nil?
        used_card_no = UsedCardNo.new(:card_name => @card.name, :card_no_code => code, :user_name => @current_user.name)
        used_card_no.card = @card
        used_card_no.card_no = @card_no
        used_card_no.user = @current_user
        used_card_no.save
      end
      
      if !used_card_no.order_id.nil?
        @card_no = CardNo.new(:code => @card_no.code)
        flash[:notice] = "您已经使用过这个卡号！"
        render "new" and return
      end
      
      if !params[:full_name].blank? && !params[:mobile_phone].blank?
        @current_user.update_attributes(:full_name => params[:full_name], :mobile_phone => params[:mobile_phone])
      end
      
      if @card.chongzhika?
        @user_money_record = UserMoneyRecord.new :pay_type => 4, :pay_code => '', :user_id => @current_user.uid, :user_name => @current_user.name, :status => 2, :record_type => 1, :amount => @card.price
        @user_money_record.save
        used_card_no.update_attribute(:order_id, @user_money_record.id)
        if @card.is_yihao?
          @card_no.update_attribute(:status, 2)
        end
        @card.increment!(:used_num)
        User.update_counters @current_user.uid , :balance => @card.price
        redirect_to card_no_path(@card_no), notice: "注卡成功,卡号：#{@card_no.code}."
      else
        redirect_to select_card_nos_path + "?used_card_no_id=" + used_card_no.id.to_s
      end
    #else
    #  flash[:notice] = "验证码错误！"
    #  render "new"
    #end
  end
  
  
  def update
    used_card_no = UsedCardNo.find(params[:used_card_no_id])
    
    if used_card_no.user_id != @current_user.uid || !used_card_no.order_id.nil?
      flash[:notice] = "非法操作！"
      redirect_to new_card_no_path and return
    end
    
    @card = Card.find(used_card_no.card_id)
    if !params[:product_ids].nil?
      if @card.select_num-@card.must_num != params[:product_ids].length
        flash[:notice] = "非法操作！"
        redirect_to select_card_nos_path + "?used_card_no_id=" + used_card_no.id.to_s and return
      end
    end
    
    card_product_ids = @card.product_array.collect! {|x| x["id"] }
    
    must_product_ids = []
    1..@card.must_num.times do |index|
      must_product_ids.push(card_product_ids.shift())      
    end
    
    params[:product_ids].each do |product_id|
      if !card_product_ids.include?(product_id.to_i)
        flash[:notice] = "非法操作！"
        redirect_to select_card_nos_path + "?used_card_no_id=" + used_card_no.id.to_s and return
      end
    end unless params[:product_ids].nil?
    
    select_products_num = must_product_ids.length
    select_products_num += params[:product_ids].length unless params[:product_ids].nil?
    
    if select_products_num != @card.select_num
      flash[:notice] = "选择的产品数量有错误！"
      redirect_to select_card_nos_path + "?used_card_no_id=" + used_card_no.id.to_s and return
    end
    
    @card_no = CardNo.find(used_card_no.card_no_id)
    
    used_card_no.transaction do
      order = Order.new
      order.user = @current_user
      order.user_name = @current_user.name
      order.ip = request.remote_ip
      order.pay_type = @card.group
      order.status = 9
      order.amount = @card.price
      order.order_type = 1
      order.item_num = @card.select_num
      order.paid_at = DateTime.now
      order.save
      order.update_attribute('code', DateTime.now.strftime("%y%m")+("%00006d" % order.id))
      must_product_ids.each do |product_id|
        product = Product.find_from_cache(product_id)
        if !product.deleted
          order.order_items.build :user_id => @current_user.uid, :user_name => @current_user.name, :status => 1, :product_id => product.id, :product_type => 1, :product_name => product.name, :origin_price => product.origin_price, :sale_price => product.sale_price, :discount_amount => 0, :is_gift => false, :num => 1
        end
      end
      params[:product_ids].each do |product_id|
        product = Product.find_from_cache(product_id)
        if !product.deleted
          order.order_items.build :user_id => @current_user.uid, :user_name => @current_user.name, :status => 1, :product_id => product.id, :product_type => 1, :product_name => product.name, :origin_price => product.origin_price, :sale_price => product.sale_price, :discount_amount => 0, :is_gift => false, :num => 1
        end
      end unless params[:product_ids].nil?
      order.save
      order.open_user_accounts
      used_card_no.update_attributes!({:order_id => order.id, :order_code => order.code})
      if @card.is_yihao?
        @card_no.update_attribute(:status, 2)
      end
      @card.increment!(:used_num)
    end
    redirect_to card_no_path(@card_no), notice: "注卡成功,卡号：#{@card_no.code}."
  end

  def show
    @used_card_no = @current_user.used_card_nos.where("card_no_id = ?", params[:id]).first
    @user_accounts = @current_user.user_accounts.where("order_code = ?", @used_card_no.order_code)
  end
  
  
  private
  
  def card_no_params
    params.require(:card_no).permit(:code, :passwd)
  end
  
end
