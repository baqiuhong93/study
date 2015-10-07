require 'test_helper'

class Admin::UserAccountsControllerTest < ActionController::TestCase
  setup do
    @admin_user_account = admin_user_accounts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_user_accounts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_user_account" do
    assert_difference('Admin::UserAccount.count') do
      post :create, admin_user_account: { effect_str: @admin_user_account.effect_str, effect_type: @admin_user_account.effect_type, product_type: @admin_user_account.product_type, status: @admin_user_account.status }
    end

    assert_redirected_to admin_user_account_path(assigns(:admin_user_account))
  end

  test "should show admin_user_account" do
    get :show, id: @admin_user_account
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_user_account
    assert_response :success
  end

  test "should update admin_user_account" do
    put :update, id: @admin_user_account, admin_user_account: { effect_str: @admin_user_account.effect_str, effect_type: @admin_user_account.effect_type, product_type: @admin_user_account.product_type, status: @admin_user_account.status }
    assert_redirected_to admin_user_account_path(assigns(:admin_user_account))
  end

  test "should destroy admin_user_account" do
    assert_difference('Admin::UserAccount.count', -1) do
      delete :destroy, id: @admin_user_account
    end

    assert_redirected_to admin_user_accounts_path
  end
end
