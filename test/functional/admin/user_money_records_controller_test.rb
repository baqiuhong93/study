require 'test_helper'

class Admin::UserMoneyRecordsControllerTest < ActionController::TestCase
  setup do
    @admin_user_money_record = admin_user_money_records(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_user_money_records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_user_money_record" do
    assert_difference('Admin::UserMoneyRecord.count') do
      post :create, admin_user_money_record: { amount: @admin_user_money_record.amount, order_code: @admin_user_money_record.order_code, pay_type: @admin_user_money_record.pay_type, record_type: @admin_user_money_record.record_type, status: @admin_user_money_record.status, user_name: @admin_user_money_record.user_name }
    end

    assert_redirected_to admin_user_money_record_path(assigns(:admin_user_money_record))
  end

  test "should show admin_user_money_record" do
    get :show, id: @admin_user_money_record
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_user_money_record
    assert_response :success
  end

  test "should update admin_user_money_record" do
    put :update, id: @admin_user_money_record, admin_user_money_record: { amount: @admin_user_money_record.amount, order_code: @admin_user_money_record.order_code, pay_type: @admin_user_money_record.pay_type, record_type: @admin_user_money_record.record_type, status: @admin_user_money_record.status, user_name: @admin_user_money_record.user_name }
    assert_redirected_to admin_user_money_record_path(assigns(:admin_user_money_record))
  end

  test "should destroy admin_user_money_record" do
    assert_difference('Admin::UserMoneyRecord.count', -1) do
      delete :destroy, id: @admin_user_money_record
    end

    assert_redirected_to admin_user_money_records_path
  end
end
