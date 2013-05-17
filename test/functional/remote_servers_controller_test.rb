require 'test_helper'

class RemoteServersControllerTest < ActionController::TestCase
  setup do
    @remote_server = remote_servers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:remote_servers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create remote_server" do
    assert_difference('RemoteServer.count') do
      post :create, remote_server: @remote_server.attributes
    end

    assert_redirected_to remote_server_path(assigns(:remote_server))
  end

  test "should show remote_server" do
    get :show, id: @remote_server
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @remote_server
    assert_response :success
  end

  test "should update remote_server" do
    put :update, id: @remote_server, remote_server: @remote_server.attributes
    assert_redirected_to remote_server_path(assigns(:remote_server))
  end

  test "should destroy remote_server" do
    assert_difference('RemoteServer.count', -1) do
      delete :destroy, id: @remote_server
    end

    assert_redirected_to remote_servers_path
  end
end
