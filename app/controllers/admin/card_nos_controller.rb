# encoding: utf-8

class Admin::CardNosController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource
  before_filter :init_card
  before_filter :init_breadcrumb_and_module_name
  layout "admin"
  
  # GET /admin/card_nos
  # GET /admin/card_nos.json
  def index
    @search = @card.card_nos.search(params[:search])
    @card_nos = @search.paginate(:page => params[:page], :per_page => GlobalSettings.per_page).order('id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @card_nos }
    end
  end

  # GET /admin/card_nos/new
  # GET /admin/card_nos/new.json
  def new

    drop_breadcrumb('新增')
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @card_no }
    end
  end

  

  # POST /admin/card_nos
  # POST /admin/card_nos.json
  def create
    prefix_names = eval(@card.prefix_names || '[]')
    if prefix_names.include?(params[:prefix_name])
      redirect_to admin_card_card_nos_path(@card), notice: "生成失败，前缀#{params[:prefix_name]}已经被使用！" and return
    end

    #同号卡判断
    if @card.is_tonghao? && @card.total_num > 0
      redirect_to admin_card_card_nos_path(@card), notice: "生成失败，同号卡只需生成一张！" and return
    end

    prefix_names.push(params[:prefix_name])

    if @card.is_tonghao? #同号卡
      @card.card_nos.build(:code => "#{@card.id}##{params[:prefix_name]}", :passwd => newpass(10))
      @card.total_num = 1
    else
      params[:num].to_i.times do |i|
        @card.card_nos.build(:code => "#{@card.id}##{params[:prefix_name]}%03d" % i, :passwd => newpass(10))
      end
      @card.total_num = @card.total_num + params[:num].to_i
    end

    @card.prefix_names = prefix_names.to_s
    if @card.save!
      redirect_to admin_card_card_nos_path(@card), notice: "卡批次创建成功."
    else
      flash[:notice] = "卡批次创建失败."
      render action: "new"
    end
    
  end

  # DELETE /admin/card_nos/1
  # DELETE /admin/card_nos/1.json
  def destroy
    @card = Card.find(params[:card_id])
    @card_no = @card.card_nos.find(params[:id])
    @card_no.destroy
    @card.decrement!(:total_num)
    respond_to do |format|
      format.html { redirect_to admin_card_path(@card) }
      format.json { head :no_content }
    end
  end
  
  
  def export
    @search = @card.card_nos.search(params[:search])
    @card_nos = @search.order('id DESC')
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def card_no_params
      params.require(:card_no).permit(:card, :code, :passwd, :status)
    end
    
    def init_card
      @card = Card.find(params[:card_id])
    end
    
    def init_breadcrumb_and_module_name
      drop_breadcrumb("卡", admin_cards_path)
      drop_breadcrumb(@card.name, admin_card_card_nos_path(@card))
      @_module_name = 'card_no'
      @__module_name = 'CardNo'
    end
    
    def newpass( len )  
        chars = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "m", "n", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]  
        newpass = ""  
        1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }  
        return newpass  
    end
end
