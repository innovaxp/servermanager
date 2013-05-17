require 'test_helper'

class WorkingCopiesControllerTest < ActionController::TestCase
  setup do
    @working_copy = working_copies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:working_copies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create working_copy" do
    assert_difference('WorkingCopy.count') do
      post :create, working_copy: @working_copy.attributes
    end

    assert_redirected_to working_copy_path(assigns(:working_copy))
  end

  test "should show working_copy" do
    get :show, id: @working_copy
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @working_copy
    assert_response :success
  end

  test "should update working_copy" do
    put :update, id: @working_copy, working_copy: @working_copy.attributes
    assert_redirected_to working_copy_path(assigns(:working_copy))
  end

  test "should destroy working_copy" do
    assert_difference('WorkingCopy.count', -1) do
      delete :destroy, id: @working_copy
    end

    assert_redirected_to working_copies_path
  end
end
