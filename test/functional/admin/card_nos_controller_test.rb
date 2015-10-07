require 'test_helper'

class Admin::CardNosControllerTest < ActionController::TestCase
  setup do
    @admin_card_no = admin_card_nos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_card_nos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_card_no" do
    assert_difference('Admin::CardNo.count') do
      post :create, admin_card_no: { code: @admin_card_no.code, passwd: @admin_card_no.passwd, status: @admin_card_no.status }
    end

    assert_redirected_to admin_card_no_path(assigns(:admin_card_no))
  end

  test "should show admin_card_no" do
    get :show, id: @admin_card_no
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_card_no
    assert_response :success
  end

  test "should update admin_card_no" do
    put :update, id: @admin_card_no, admin_card_no: { code: @admin_card_no.code, passwd: @admin_card_no.passwd, status: @admin_card_no.status }
    assert_redirected_to admin_card_no_path(assigns(:admin_card_no))
  end

  test "should destroy admin_card_no" do
    assert_difference('Admin::CardNo.count', -1) do
      delete :destroy, id: @admin_card_no
    end

    assert_redirected_to admin_card_nos_path
  end
end
