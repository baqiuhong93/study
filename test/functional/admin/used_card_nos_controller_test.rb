require 'test_helper'

class Admin::UsedCardNosControllerTest < ActionController::TestCase
  setup do
    @admin_used_card_no = admin_used_card_nos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_used_card_nos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_used_card_no" do
    assert_difference('Admin::UsedCardNo.count') do
      post :create, admin_used_card_no: { code: @admin_used_card_no.code, order_code: @admin_used_card_no.order_code, user_name: @admin_used_card_no.user_name }
    end

    assert_redirected_to admin_used_card_no_path(assigns(:admin_used_card_no))
  end

  test "should show admin_used_card_no" do
    get :show, id: @admin_used_card_no
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_used_card_no
    assert_response :success
  end

  test "should update admin_used_card_no" do
    put :update, id: @admin_used_card_no, admin_used_card_no: { code: @admin_used_card_no.code, order_code: @admin_used_card_no.order_code, user_name: @admin_used_card_no.user_name }
    assert_redirected_to admin_used_card_no_path(assigns(:admin_used_card_no))
  end

  test "should destroy admin_used_card_no" do
    assert_difference('Admin::UsedCardNo.count', -1) do
      delete :destroy, id: @admin_used_card_no
    end

    assert_redirected_to admin_used_card_nos_path
  end
end
