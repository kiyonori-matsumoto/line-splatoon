require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = users :sample1
  end

  test 'should get show' do
    get :show, line_uid: @user
    assert_response :success
  end

  test 'should get edit' do
    get :edit, line_uid: @user
    assert_response :success
  end

  test 'should get update' do
    patch :update, line_uid: @user, user: { stat_ink_id: 'ZZZZ' }
    assert_response :success
    @user.reload
    assert_equal 'ZZZZ', @user.stat_ink_id
    assert_template 'users/show'
  end
end
