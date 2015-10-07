require 'test_helper'

class Admin::CardsControllerTest < ActionController::TestCase
  setup do
    @admin_card = admin_cards(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_cards)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_card" do
    assert_difference('Admin::Card.count') do
      post :create, admin_card: { card_text: @admin_card.card_text, card_type: @admin_card.card_type, description: @admin_card.description, expired_at: @admin_card.expired_at, group: @admin_card.group, name: @admin_card.name, onlined_at: @admin_card.onlined_at, price: @admin_card.price, status: @admin_card.status, total_num: @admin_card.total_num }
    end

    assert_redirected_to admin_card_path(assigns(:admin_card))
  end

  test "should show admin_card" do
    get :show, id: @admin_card
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_card
    assert_response :success
  end

  test "should update admin_card" do
    put :update, id: @admin_card, admin_card: { card_text: @admin_card.card_text, card_type: @admin_card.card_type, description: @admin_card.description, expired_at: @admin_card.expired_at, group: @admin_card.group, name: @admin_card.name, onlined_at: @admin_card.onlined_at, price: @admin_card.price, status: @admin_card.status, total_num: @admin_card.total_num }
    assert_redirected_to admin_card_path(assigns(:admin_card))
  end

  test "should destroy admin_card" do
    assert_difference('Admin::Card.count', -1) do
      delete :destroy, id: @admin_card
    end

    assert_redirected_to admin_cards_path
  end
end
