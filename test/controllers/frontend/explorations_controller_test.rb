require 'test_helper'

class Frontend::ExplorationsControllerTest < ActionController::TestCase
  setup do
    @frontend_exploration = frontend_explorations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:frontend_explorations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create frontend_exploration" do
    assert_difference('Frontend::Exploration.count') do
      post :create, frontend_exploration: {  }
    end

    assert_redirected_to frontend_exploration_path(assigns(:frontend_exploration))
  end

  test "should show frontend_exploration" do
    get :show, id: @frontend_exploration
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @frontend_exploration
    assert_response :success
  end

  test "should update frontend_exploration" do
    patch :update, id: @frontend_exploration, frontend_exploration: {  }
    assert_redirected_to frontend_exploration_path(assigns(:frontend_exploration))
  end

  test "should destroy frontend_exploration" do
    assert_difference('Frontend::Exploration.count', -1) do
      delete :destroy, id: @frontend_exploration
    end

    assert_redirected_to frontend_explorations_path
  end
end
