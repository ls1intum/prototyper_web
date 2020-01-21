require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    @release = releases(:one)

    @feedback = @release.feedbacks.build(user: @user, title:"Test title", plain: "Lorem ipsom bla")
  end

  test "should be valid" do
    assert @feedback.valid?, @feedback.errors.full_messages
  end

  test "user id should be present" do
    @feedback.user_id = nil
    assert_not @feedback.valid?
  end

  test "release id should be present" do
    @feedback.release_id = nil
    assert_not @feedback.valid?
  end

  test "title should be present" do
    @feedback.title = "     "
    assert_not @feedback.valid?
  end

  test "title should not be too long" do
    @feedback.title = "a" * 101
    assert_not @feedback.valid?
  end

  test "text should be present" do
    @feedback.text = "     "
    assert_not @feedback.valid?
  end

  test "text should not be too long" do
    @feedback.text = "a" * 1001
    assert_not @feedback.valid?
  end

end
