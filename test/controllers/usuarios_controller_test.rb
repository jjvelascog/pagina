require 'test_helper'

class UsuariosControllerTest < ActionController::TestCase
  test "should get actualizar" do
    get :actualizar
    assert_response :success
  end

end
