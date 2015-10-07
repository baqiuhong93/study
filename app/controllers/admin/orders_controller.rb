# encoding: utf-8

class Admin::OrdersController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource
  before_filter :init_breadcrumb_and_module_name
  layout "admin"
  
  # GET /admin/orders
  # GET /admin/orders.json
  def index
    @search = Order.search(params[:search])
    @orders = @search.paginate(:page => params[:page], :per_page => GlobalSettings.per_page).order('id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orders }
    end
  end

  # GET /admin/orders/1
  # GET /admin/orders/1.json
  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order }
    end
  end

  # GET /admin/orders/new
  # GET /admin/orders/new.json
  def new
    @order = Order.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order }
    end
  end

  # GET /admin/orders/1/edit
  def edit
    @order = Order.find(params[:id])
  end

  # POST /admin/orders
  # POST /admin/orders.json
  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to admin_order_path(@order), notice: 'Order was successfully created.' }
        format.json { render json: @order, status: :created, location: @order }
      else
        format.html { render action: "new" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/orders/1
  # PATCH/PUT /admin/orders/1.json
  def update
    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update_attributes(order_params)
        format.html { redirect_to admin_order_path(@order), notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def export
    @search = Order.search(params[:search])
    @orders = @search.order('id DESC')
  end
  
  def open
    order = Order.find(params[:id])
    if order.can_open_product_order_by_admin?
      order.transaction do
        order.update_attributes({:status => 9, :paid_at => DateTime.now, :admin_user_id => current_user.uid, :admin_user_name => current_user.name})
        order.open_user_accounts
      end
      redirect_to edit_admin_order_path(order), notice: "订单开通成功."
    else
      redirect_to edit_admin_order_path(order), notice: "订单开通失败."
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def order_params
      params.require(:order).permit(:amount, :balance_amount, :code, :discount_amount, :gift_num, :ip, :item_num, :manage_remark, :order_type, :pay_code, :pay_id, :pay_type, :remark, :status, :user, :user_name)
    end
    
    def init_breadcrumb_and_module_name
      drop_breadcrumb("订单", admin_orders_path)
      @_module_name = 'order'
      @__module_name = 'Order'
      @_module_new = false
      @_module_delete = false
    end
end
