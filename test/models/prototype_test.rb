require 'test_helper'

class PrototypeTest < ActiveSupport::TestCase

  def setup
    @app = apps(:one)

    @prototype = @app.releases.create(type: "Prototype", version: "1.0",
                                      description: "Lorem ipsum",
                                      url: "http://www.address.com/adsd/1/sda" )
  end

  test "should be valid" do
    assert @prototype.valid?
  end

  test "url should be present" do
    @prototype.url = "     "
    assert_not @prototype.valid?
  end

  test "url should not be too long" do
    @prototype.url = "a" * 101
    assert_not @prototype.valid?
  end
end
