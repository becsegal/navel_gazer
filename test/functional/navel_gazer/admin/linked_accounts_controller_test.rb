require 'test_helper'

module NavelGazer
  class Admin::LinkedAccountsControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end
  
  end
end
