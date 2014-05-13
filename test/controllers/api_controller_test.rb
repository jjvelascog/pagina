require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "should get pedirProducto" do
    get :pedirProducto
    assert_response :success
  end

end
