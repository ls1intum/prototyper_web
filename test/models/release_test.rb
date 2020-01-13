require 'test_helper'

class ReleaseTest < ActiveSupport::TestCase
  def setup
    @app = apps(:one)

    @release = @app.releases.create(type: "Prototype", version: "1.0",
                                      description: "Lorem ipsum",
                                      url: "apps/adsd/1/sda" )
  end

  test "should be valid" do
    assert @release.valid?
  end

  test "type should be present" do
    @release.type = "     "
    assert_not @release.valid?
  end

  test "version should be present" do
    @release.version = "     "
    assert_not @release.valid?
  end

  test "version should not be too long" do
    @release.version = "a" * 31
    assert_not @release.valid?
  end

  test "description should be present" do
    @release.description = "     "
    assert_not @release.valid?
  end

  test "description should not be too long" do
    @release.description = "a" * 501
    assert_not @release.valid?
  end

end
