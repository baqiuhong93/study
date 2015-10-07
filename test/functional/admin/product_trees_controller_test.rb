require 'test_helper'

class Admin::ProductTreesControllerTest < ActionController::TestCase
  setup do
    @admin_product_tree = admin_product_trees(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_product_trees)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_product_tree" do
    assert_difference('Admin::ProductTree.count') do
      post :create, admin_product_tree: { audition_path: @admin_product_tree.audition_path, description: @admin_product_tree.description, name: @admin_product_tree.name, order_num: @admin_product_tree.order_num }
    end

    assert_redirected_to admin_product_tree_path(assigns(:admin_product_tree))
  end

  test "should show admin_product_tree" do
    get :show, id: @admin_product_tree
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_product_tree
    assert_response :success
  end

  test "should update admin_product_tree" do
    put :update, id: @admin_product_tree, admin_product_tree: { audition_path: @admin_product_tree.audition_path, description: @admin_product_tree.description, name: @admin_product_tree.name, order_num: @admin_product_tree.order_num }
    assert_redirected_to admin_product_tree_path(assigns(:admin_product_tree))
  end

  test "should destroy admin_product_tree" do
    assert_difference('Admin::ProductTree.count', -1) do
      delete :destroy, id: @admin_product_tree
    end

    assert_redirected_to admin_product_trees_path
  end
end
