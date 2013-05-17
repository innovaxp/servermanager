require 'test_helper'

class UploadServicesControllerTest < ActionController::TestCase
  setup do
    @upload_service = upload_services(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:upload_services)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create upload_service" do
    assert_difference('UploadService.count') do
      post :create, upload_service: @upload_service.attributes
    end

    assert_redirected_to upload_service_path(assigns(:upload_service))
  end

  test "should show upload_service" do
    get :show, id: @upload_service
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @upload_service
    assert_response :success
  end

  test "should update upload_service" do
    put :update, id: @upload_service, upload_service: @upload_service.attributes
    assert_redirected_to upload_service_path(assigns(:upload_service))
  end

  test "should destroy upload_service" do
    assert_difference('UploadService.count', -1) do
      delete :destroy, id: @upload_service
    end

    assert_redirected_to upload_services_path
  end
end
