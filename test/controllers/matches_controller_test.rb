require 'test_helper'

class MatchesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in users(:diego)

    get authenticated_root_path
    assert_response :success
  end
end
