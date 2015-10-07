# encoding: utf-8

class Admin::UserMoneyRecordsController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource
  before_filter :init_breadcrumb_and_module_name
  layout "admin"

  # GET /admin/user_money_records
  # GET /admin/user_money_records.json
  def index
    @search = UserMoneyRecord.search(params[:search])
    @user_money_records = @search.paginate(:page => params[:page], :per_page => GlobalSettings.per_page).order('id DESC')
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def user_money_record_params
      params.require(:user_money_record).permit(:amount, :order, :order_code, :pay_type, :record_type, :status, :user, :user_name)
    end
    
    def init_breadcrumb_and_module_name
      drop_breadcrumb("账户充值记录", admin_user_money_records_path)
      @_module_name = 'user_money_record'
      @__module_name = 'UserMoneyRecord'
      @_module_new = false
    end
end
