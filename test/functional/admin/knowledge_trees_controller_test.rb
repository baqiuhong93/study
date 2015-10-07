require 'test_helper'

class Admin::KnowledgeTreesControllerTest < ActionController::TestCase
  setup do
    @admin_knowledge_tree = admin_knowledge_trees(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_knowledge_trees)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_knowledge_tree" do
    assert_difference('Admin::KnowledgeTree.count') do
      post :create, admin_knowledge_tree: { audition_path: @admin_knowledge_tree.audition_path, course_num: @admin_knowledge_tree.course_num, description: @admin_knowledge_tree.description, listen_path: @admin_knowledge_tree.listen_path, name: @admin_knowledge_tree.name, order_num: @admin_knowledge_tree.order_num }
    end

    assert_redirected_to admin_knowledge_tree_path(assigns(:admin_knowledge_tree))
  end

  test "should show admin_knowledge_tree" do
    get :show, id: @admin_knowledge_tree
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_knowledge_tree
    assert_response :success
  end

  test "should update admin_knowledge_tree" do
    put :update, id: @admin_knowledge_tree, admin_knowledge_tree: { audition_path: @admin_knowledge_tree.audition_path, course_num: @admin_knowledge_tree.course_num, description: @admin_knowledge_tree.description, listen_path: @admin_knowledge_tree.listen_path, name: @admin_knowledge_tree.name, order_num: @admin_knowledge_tree.order_num }
    assert_redirected_to admin_knowledge_tree_path(assigns(:admin_knowledge_tree))
  end

  test "should destroy admin_knowledge_tree" do
    assert_difference('Admin::KnowledgeTree.count', -1) do
      delete :destroy, id: @admin_knowledge_tree
    end

    assert_redirected_to admin_knowledge_trees_path
  end
end
