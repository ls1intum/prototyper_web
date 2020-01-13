require 'test_helper'

class AppTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    @app = @user.apps.build(name: "Lorem ipsum", bundle_id:"com.apple.test", icon: "test.jpg")
  end

  test "should be valid" do
    assert @app.valid?, @app.errors.full_messages
  end

  test "user id should be present" do
    @app.user_id = nil
    assert_not @app.valid?
  end

  test "name should be present" do
    @app.name = "     "
    assert_not @app.valid?
  end

  test "name should not be too long" do
    @app.name = "a" * 101
    assert_not @app.valid?
  end

  test "bundle_id should be present" do
    @app.bundle_id = "     "
    assert_not @app.valid?
  end

  test "bundle_id should not be too long" do
    @app.bundle_id = "a" * 51
    assert_not @app.valid?
  end

  test "user should be present" do
    @app.user_id = nil
    assert_not @app.valid?
  end

end
