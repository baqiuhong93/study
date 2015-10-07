# encoding: utf-8

class Admin::CardsController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource
  before_filter :init_breadcrumb_and_module_name
  layout "admin"
  
  # GET /admin/cards
  # GET /admin/cards.json
  def index
    @search = Card.search(params[:search])
    @cards = @search.paginate(:page => params[:page], :per_page => GlobalSettings.per_page).order('id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cards }
    end
  end

  # GET /admin/cards/1
  # GET /admin/cards/1.json
  def show
    @card = Card.find(params[:id])
    @card_nos = @card.card_nos.paginate(:page => params[:page], :per_page => 10).order('id DESC')
    
    drop_breadcrumb(@card.name, admin_card_path(@card))
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @card }
    end
  end

  # GET /admin/cards/new
  # GET /admin/cards/new.json
  def new
    @card = Card.new
    
    drop_breadcrumb('新增')
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @card }
    end
  end

  # GET /admin/cards/1/edit
  def edit
    @card = Card.find(params[:id])
    
    drop_breadcrumb(@card.name, admin_card_path(@card))
    drop_breadcrumb('修改')
  end

  # POST /admin/cards
  # POST /admin/cards.json
  def create
    @card = Card.new(create_card_params)
    @card.used_num = 0
    respond_to do |format|
      if @card.save
        format.html { redirect_to admin_card_path(@card), notice: '卡创建成功.' }
        format.json { render json: @card, status: :created, location: @card }
      else
        format.html { render action: "new" }
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/cards/1
  # PATCH/PUT /admin/cards/1.json
  def update
    @card = Card.find(params[:id])

    respond_to do |format|
      if @card.update_attributes(update_card_params)
        format.html { redirect_to admin_card_path(@card), notice: '卡修改成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/cards/1
  # DELETE /admin/cards/1.json
  def destroy
    @card = Card.find(params[:id])
    if @card.total_num > 0
      respond_to do |format|
        format.html { redirect_to admin_cards_path, notice: '卡删除失败，请先删除卡下面的卡号.' }
        format.json { head :no_content }
      end
      return
    end
    @card.destroy

    respond_to do |format|
      format.html { redirect_to admin_cards_path }
      format.json { head :no_content }
    end
  end
  
  def generate_card_nos
    @card = Card.find(params[:id])
    
    prefix_names = eval(@card.prefix_names || '[]')
    if prefix_names.include?(params[:prefix_name])
      redirect_to admin_card_path(@card), notice: "生成失败，前缀#{params[:prefix_name]}已经被使用！" and return
    end
    
    #同号卡判断
    if @card.card_type == 1 && @card.total_num > 0
      redirect_to admin_card_path(@card), notice: "生成失败，同号卡只需生成一张！" and return
    end
    
    prefix_names.push(params[:prefix_name])
    
    if @card.card_type == 1 #同号卡
      @card.card_nos.build(:code => "#{@card.id}##{params[:prefix_name]}", :passwd => newpass(10))
      @card.total_num = 1
    else
      params[:num].to_i.times do |i|
        @card.card_nos.build(:code => "#{@card.id}##{params[:prefix_name]}%03d" % i, :passwd => newpass(10))
      end
      @card.total_num = @card.total_num + params[:num].to_i
    end
    
    @card.prefix_names = prefix_names.to_s
    @card.save!
    respond_to do |format|
      format.html { redirect_to admin_card_path(@card), notice: '卡批次创建成功.' }
      format.json { head :no_content }
    end
  end


  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def create_card_params
      params.require(:card).permit(:card_type, :description, :expired_at, :group, :name, :onlined_at, :price, :status, :total_num, :product_ids, :select_num, :must_num, :products)
    end
    
    def update_card_params
      params.require(:card).permit(:description, :expired_at, :group, :name, :onlined_at, :price, :status, :total_num, :product_ids, :select_num, :must_num, :products)
    end
    
    def init_breadcrumb_and_module_name
      drop_breadcrumb("卡", admin_cards_path)
      @_module_name = 'card'
      @__module_name = 'Card'
    end
    
    def newpass( len )  
        chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a  
        newpass = ""  
        1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }  
        return newpass  
    end
end
