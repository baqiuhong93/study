# encoding: utf-8

class Admin::UsedCardNosController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource
  before_filter :init_breadcrumb_and_module_name
  layout "admin"
  
  # GET /admin/used_card_nos
  # GET /admin/used_card_nos.json
  def index
    @search = UsedCardNo.search(params[:search])
    @used_card_nos = @search.paginate(:page => params[:page], :per_page => GlobalSettings.per_page).order('id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @used_card_nos }
    end
  end

  # GET /admin/used_card_nos/1
  # GET /admin/used_card_nos/1.json
  def show
    @used_card_no = UsedCardNo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @used_card_no }
    end
  end

  # GET /admin/used_card_nos/new
  # GET /admin/used_card_nos/new.json
  def new
    @used_card_no = UsedCardNo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @used_card_no }
    end
  end

  # GET /admin/used_card_nos/1/edit
  def edit
    @used_card_no = UsedCardNo.find(params[:id])
  end

  # POST /admin/used_card_nos
  # POST /admin/used_card_nos.json
  def create
    @used_card_no = UsedCardNo.new(used_card_no_params)

    respond_to do |format|
      if @used_card_no.save
        format.html { redirect_to admin_used_card_no_path(@used_card_no), notice: 'Used card no was successfully created.' }
        format.json { render json: @used_card_no, status: :created, location: @used_card_no }
      else
        format.html { render action: "new" }
        format.json { render json: @used_card_no.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/used_card_nos/1
  # PATCH/PUT /admin/used_card_nos/1.json
  def update
    @used_card_no = UsedCardNo.find(params[:id])

    respond_to do |format|
      if @used_card_no.update_attributes(used_card_no_params)
        format.html { redirect_to admin_used_card_no_path(@used_card_no), notice: 'Used card no was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @used_card_no.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def used_card_no_params
      params.require(:used_card_no).permit(:card, :card_no, :code, :order_code, :user, :user_name)
    end
    
    def init_breadcrumb_and_module_name
      drop_breadcrumb("注卡", admin_used_card_nos_path)
      @_module_name = 'used_card_no'
      @__module_name = 'UsedCardNo'
      @_module_new = false
    end
end
