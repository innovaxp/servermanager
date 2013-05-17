require 'test_helper'

class BackupConfigurationsControllerTest < ActionController::TestCase
  setup do
    @backup_configuration = backup_configurations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:backup_configurations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create backup_configuration" do
    assert_difference('BackupConfiguration.count') do
      post :create, backup_configuration: @backup_configuration.attributes
    end

    assert_redirected_to backup_configuration_path(assigns(:backup_configuration))
  end

  test "should show backup_configuration" do
    get :show, id: @backup_configuration
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @backup_configuration
    assert_response :success
  end

  test "should update backup_configuration" do
    put :update, id: @backup_configuration, backup_configuration: @backup_configuration.attributes
    assert_redirected_to backup_configuration_path(assigns(:backup_configuration))
  end

  test "should destroy backup_configuration" do
    assert_difference('BackupConfiguration.count', -1) do
      delete :destroy, id: @backup_configuration
    end

    assert_redirected_to backup_configurations_path
  end
end
