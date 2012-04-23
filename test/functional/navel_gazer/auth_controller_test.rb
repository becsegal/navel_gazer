require 'test_helper'

module NavelGazer
  class AuthControllerTest < ActionController::TestCase
    test "should get connect" do
      get :connect
      assert_response :success
    end
  
    test "should get disconnect" do
      get :disconnect
      assert_response :success
    end
  
    test "should get failure" do
      get :failure
      assert_response :success
    end
  
    test "should get callback" do
      get :callback
      assert_response :success
    end
  
  end
end
