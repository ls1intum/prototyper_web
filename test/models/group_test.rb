require 'test_helper'

class GroupTest < ActiveSupport::TestCase

  def setup
    @app = apps(:one)

    @group = @app.groups.create(name: "Group")
  end

  test "should be valid" do
    assert @group.valid?
  end

  test "name should be present" do
    @group.name = "     "
    assert_not @group.valid?
  end

  test "name should not be too long" do
    @group.name = "a" * 101
    assert_not @group.valid?
  end

  test "app id should be present" do
    @group.app_id = nil
    assert_not @group.valid?
  end
end
