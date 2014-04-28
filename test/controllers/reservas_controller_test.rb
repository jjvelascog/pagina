require 'test_helper'

class ReservasControllerTest < ActionController::TestCase
  test "should get actualizar" do
    get :actualizar
    assert_response :success
  end

end
