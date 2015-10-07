# encoding: utf-8

class Admin::UserAccountsController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource
  before_filter :init_breadcrumb_and_module_name
  layout "admin"
  
  
  # GET /admin/user_accounts
  # GET /admin/user_accounts.json
  def index
    @search = UserAccount.search(params[:search])
    @user_accounts = @search.paginate(:page => params[:page], :per_page => GlobalSettings.per_page).order('id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_accounts }
    end
  end

  # GET /admin/user_accounts/1
  # GET /admin/user_accounts/1.json
  def show
    @user_account = UserAccount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_account }
    end
  end

  # GET /admin/user_accounts/new
  # GET /admin/user_accounts/new.json
  def new
    @user_account = UserAccount.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_account }
    end
  end

  # GET /admin/user_accounts/1/edit
  def edit
    @user_account = UserAccount.find(params[:id])
  end

  # POST /admin/user_accounts
  # POST /admin/user_accounts.json
  def create
    @user_account = UserAccount.new(user_account_params)

    respond_to do |format|
      if @user_account.save
        format.html { redirect_to admin_user_account_path(@user_account), notice: 'User account was successfully created.' }
        format.json { render json: @user_account, status: :created, location: @user_account }
      else
        format.html { render action: "new" }
        format.json { render json: @user_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/user_accounts/1
  # PATCH/PUT /admin/user_accounts/1.json
  def update
    @user_account = UserAccount.find(params[:id])

    respond_to do |format|
      if @user_account.update_attributes(user_account_params)
        format.html { redirect_to admin_user_account_path(@user_account), notice: 'User account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/user_accounts/1
  # DELETE /admin/user_accounts/1.json
  def destroy
    @user_account = UserAccount.find(params[:id])
    @user_account.reversion_status

    respond_to do |format|
      format.html { redirect_to admin_user_accounts_path }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def user_account_params
      params.require(:admin_user_account).permit(:effect_str, :effect_type, :order, :order_item, :product, :product_type, :status, :user)
    end
    
    def init_breadcrumb_and_module_name
      drop_breadcrumb("听课账号", admin_user_accounts_path)
      @_module_name = 'user_account'
      @__module_name = 'UserAccount'
      @_module_new = false
    end
end
