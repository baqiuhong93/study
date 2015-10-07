# encoding: utf-8

class BalancesController < ApplicationController
  before_filter :login_required
  
  def index
    
  end

  def create
    recharge_amount = params[:recharge_amount]
    if recharge_amount.nil? || recharge_amount == ''
      flash[:notice] = "充值金额不能为空!"
      redirect_to balances_index_path and return
    end
    
    if recharge_amount.to_i <= 0
      flash[:notice] = "充值金额必须大于0元!"
      redirect_to balances_index_path and return
    end
    
    @order = Order.new
    @order.user_id = current_user.uid
    @order.user_name = current_user.name
    @order.ip = request.remote_ip
    @order.status = 1
    @order.amount = recharge_amount
    @order.order_type = 2
    @order.item_num = 0
    if @order.save
      @order.update_attribute('code', DateTime.now.strftime("%y%m")+("%00006d" % @order.id))
      redirect_to balances_show(:id => @order.code), notice: '订单创建成功.'
    else
      render "new"
    end
  end

  def show
    @order = Order.where("code = ?", params[:id]).first
  end
end
