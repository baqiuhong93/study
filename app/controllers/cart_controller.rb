# encoding: utf-8

class CartController < ApplicationController
  before_filter :login_required, :only => [:confirm, :create]
  before_filter :current_user, :except => [:confirm, :create]
  layout :set_layout_dync
  
  def index
    
  end
  
  def new
    
  end
  
  def create
    cart =  CartCookieUtil.get_cart(session, cookies)
    @order = Order.new params.require(:order).permit(:pay_type, :pay_code, :remark, :balance_amount)
    if !Order.pay_type_front_hash.has_key?(params[:order][:pay_type].to_i)
      flash[:notice] = '请选择正确的支付方式！'
      render "confirm" and return
    end
    
    if @order.balance_amount < 0
      flash[:notice] = '数据非法！'
      render "confirm" and return
    end
    
    if @order.balance_amount > @current_user.now_balance
      flash[:notice] = '订单使用账户余额大于账户余额！'
      render "confirm" and return
    end
    
    if @order.pay_type != 10
      @order.pay_code = ''
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
      @order.code = DateTime.now.strftime("%y%m")+("%00006d" % @order.id)
      cart.cartItem.each do |k,v|
        @order.order_items.build :user_id => @current_user.uid, :user_name => @current_user.name, :status => 1, :product_id => v.id, :product_type => 1, :product_name => v.name, :origin_price => v.origin_price, :sale_price => v.sale_price, :discount_amount => 0, :is_gift => false, :num => v.num
      end
      @order.save
      @order.open_user_accounts if @order.yidaozhang?
    end
   
    CartCookieUtil.clear_cart(session, cookies)
    redirect_to success_order_path(:id => @order.code)
  end
  
  def add
    product = Product.find_from_cache(params[:id])
    respond_to do |format|
      if product.effective?
        CartCookieUtil.add_to_cart(session, cookies, params[:id])
        format.mobile { redirect_to cart_index_path, :notice => "产品添加成功!" }
        format.html { redirect_to cart_index_path, :notice => "产品添加成功!" }
        format.json { render json: {'status' => 'success', 'msg' => '产品添加成功!'} }
      else
        format.mobile { redirect_to cart_index_path, :notice => "产品状态无效!" }
        format.html { redirect_to cart_index_path, :notice => "产品状态无效!" }
        format.json { render json: {'status' => 'error', 'msg' => '产品状态无效!'} }
      end
    end
  end
  
  def confirm
    cart =  CartCookieUtil.get_cart(session, cookies)
    if cart.empty?
      redirect_to cart_index_path, notice: '购物车不能为空！' and return
    end
    @order = Order.new
  end
  
  def destroy
    product_id = params[:id]
    CartCookieUtil.remove_from_cart(session, cookies, product_id)
    redirect_to cart_index_path
  end

  def list
    respond_to do |format|
      format.html { redirect_to cart_index_path }
      format.json { 
        cart =  CartCookieUtil.get_cart(session, cookies)
        if params[:callback].blank?
          render json: cart
        else
          render :text => params[:callback] + "(#{cart.to_json})"
        end
      }
    end
  end
end
