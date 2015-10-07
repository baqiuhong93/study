# encoding: utf-8
class ProductsController < ApplicationController
  
  def index
    @search = Product.search(params[:search])
    @products = @search.paginate(:page => params[:page], :per_page => GlobalSettings.per_page).where("deleted = ? and sale = ?", false, true).order('available DESC, sortrank ASC, created_at DESC')
    render :layout => false
  end

  def search
    order_type = {"default" => "available DESC, sortrank ASC, created_at DESC","1" => "sale_num DESC", "2" => "sale_num ASC", "3" => "praise_num DESC", "4" => "praise_num ASC", "5" => "id DESC", "6" => "id ASC", "7" => "sale_price DESC", "8" => "sale_price ASC"}
    @search = Product.search(params[:search])
    @products = @search.where("deleted = ? and sale = ?", false, true).order(order_type.has_key?(params[:order_type]) ? order_type[params[:order_type]] : order_type["default"]).paginate(:page => params[:page], :per_page => 15)
    render :layout => false
  end

  def show
    @product = Product.where("code = ?", params[:id]).first
    @product.incr_click_num
    render :layout => false
  end
  
  def praise
    @product = Product.find(params[:id])
    _p_n = @product.incr_praise_num
    render :json => {"status" => "success", "msg" => "赞成功!", "praise_num" => _p_n}
  end
end
