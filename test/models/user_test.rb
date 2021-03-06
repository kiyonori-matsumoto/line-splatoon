require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(line_uid: 'sample')
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'should not be valid' do
    @user.line_uid = ''
    assert_not @user.valid?
  end

  test 'line_message_state must enum' do
    assert_raise(ArgumentError) { @user.line_message_state = :not }
    @user.line_message_state = :initial # no error should raised
  end
end
