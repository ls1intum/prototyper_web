require 'test_helper'

class ReleaseMailerTest < ActionMailer::TestCase
  test "new_verion_available" do
    mail = ReleaseMailer.new_verion_available
    assert_equal "New verion available", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "added_to_release_group" do
    mail = ReleaseMailer.added_to_release_group
    assert_equal "Added to release group", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
