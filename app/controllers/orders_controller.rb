# encoding: utf-8

class OrdersController < ApplicationController
  
  before_filter :login_required
  layout :set_layout_dync
  def index
    @orders = @current_user.orders
    if !params[:code].blank?
      @orders = @orders.where("code = ?", params[:code])
    end
    if !params[:status].blank?
      @orders = @orders.where("status = ?", params[:status])
    end
    if !params[:pay_type].blank?
      @orders = @orders.where("pay_type = ?", params[:pay_type])
    end
    @orders = @orders.paginate(:page => params[:page], :per_page => 8).order("id DESC")
    @weifukuan_count = @current_user.orders.where("status = 1").count()
    @yifukuan_count = @current_user.orders.where("status = 9").count()
    @yiquxiao_count = @current_user.orders.where("status = -1").count()
  end
  
  def show
    @order = @current_user.orders.where("code = ?", params[:id]).first
    #if @order.zhifubao? && @order.status == 1
      #@alipay_str = Net::HTTP.get(GlobalSettings.pay_host, "/alipay/alipayapi.jsp?WIDout_trade_no=#{@order.code}&WIDout_total_fee=#{@order.total_amount}&WIDout_defaultbank=#{@order.pay_code}", GlobalSettings.pay_port).force_encoding('UTF-8')
    #end
  end
  
  def pay
    @order = @current_user.orders.where("code = ?", params[:id]).first
    if @order.zhifubao? && @order.weifukuan? && !session[:mobile_view]
      @pay_str = Net::HTTP.get(GlobalSettings.pay_host, "/alipay/alipayapi.jsp?WIDout_trade_no=#{@order.code}&WIDout_total_fee=#{@order.total_amount}&WIDout_defaultbank=#{@order.pay_code}", GlobalSettings.pay_port).force_encoding('UTF-8')
    end
    if @order.zhifubao? && @order.weifukuan? && session[:mobile_view]
      @pay_str = Net::HTTP.get(GlobalSettings.pay_host, "/alipay/wapalipayapi.jsp?WIDout_trade_no=#{@order.code}&WIDtotal_fee=#{@order.total_amount}&WIDout_defaultbank=#{@order.pay_code}", GlobalSettings.pay_port).force_encoding('UTF-8')
    end
    if @order.kuaiqian? && @order.weifukuan?
      @pay_str = Net::HTTP.get(GlobalSettings.pay_host, "/99bill/send.jsp?orderId=#{@order.code}&orderAmount=#{@order.total_amount*100}&orderTime=#{@order.created_at.strftime("%Y%m%d%H%M%S")}&payType=#{@order.pay_type}&bankId=#{@order.pay_code}&email=#{@current_user.email}", GlobalSettings.pay_port).force_encoding('UTF-8')
    end
    render :layout => false
  end
  
  def edit
    @order = @current_user.orders.where("code = ?", params[:id]).first
    if !@order.weifukuan?
      redirect_to order_path(:id => @order.code), notice: '订单状态不正确！' and return
    end
  end
  
  def update
    @order = @current_user.orders.where("code = ?", params[:id]).first
    if !Order.pay_type_front_hash.has_key?(params[:order][:pay_type].to_i)
      flash[:notice] = "请选择正确的支付方式！"
      render action: "edit" and return
    end
    if params[:order][:pay_type].to_i == 10
      if !Order.pay_code_hash.has_key?(params[:order][:pay_code])
        flash[:notice] = "请选择正确的支付方式！"
        render action: "edit" and return
      end
    end
    if params[:order][:pay_type].to_i == 10
      @order.update_attributes(:pay_type => params[:order][:pay_type], :pay_code => params[:order][:pay_code])
    else
      @order.update_attributes(:pay_type => params[:order][:pay_type], :pay_code => '')
    end
    redirect_to order_path(:id => @order.code)
  end
  
  def create
    cart =  CartCookieUtil.get_cart(session, cookies)
    @order = Order.new params.require(:order).permit(:pay_type, :pay_code, :remark, :invoice_name)
    if !Order.pay_type_front_hash.has_key?(params[:order][:pay_type])
      redirect_to confirm_cart_index_path(@order), notice: '请选择正确的支付方式！'
      
      return
    end
    
    @order.transaction do
      @order.user_id = @current_user.uid
      @order.user_name = @current_user.name
      @order.ip = request.remote_ip
      @order.status = 1
      @order.amount = cart.get_amount
      @order.order_type = 1
      @order.item_num = cart.cartItem.size
      @order.save
      @order.update_attribute('code', DateTime.now.strftime("%y%m")+("%00006d" % @order.id))
      cart.cartItem.each do |k,v|
        @order.order_items.build :user_id => @current_user.uid, :user_name => @current_user.name, :status => 1, :product_id => v.id, :product_type => 1, :product_name => v.name, :origin_price => v.origin_price, :sale_price => v.sale_price, :discount_amount => 0, :is_gift => false
      end
      @order.save
    end
   
    CartCookieUtil.clear_cart(session, cookies)
    redirect_to success_order_path(:id => @order.code)
  end
  
  def success
    @order = @current_user.orders.where("code = ?", params[:id]).first
  end
  
  
  def destroy
    @order = @current_user.orders.where("code = ?", params[:id]).first
    @order.transaction do
      if @order.weifukuan?
        @order.update_attribute(:status, -1)
      end
    end
    respond_to do |format|
      format.mobile { redirect_to orders_path }
      format.html { redirect_to orders_path }
      format.json { head :no_content }
    end
  end
end
