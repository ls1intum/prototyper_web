require 'test_helper'

class DownloadTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    @release = releases(:one)

    @download = @release.downloads.build(user: @user)
  end

  test "should be valid" do
    assert @download.valid?, @download.errors.full_messages
  end

  test "user id should be present" do
    @download.user_id = nil
    assert_not @download.valid?
  end

  test "release id should be present" do
    @download.release_id = nil
    assert_not @download.valid?
  end
end
