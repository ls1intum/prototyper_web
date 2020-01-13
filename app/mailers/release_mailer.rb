class ReleaseMailer < ApplicationMailer

  def new_version_available(user, release, group, main_release, token)
    @user = user
    @release = release
    @group = group
    @main_release = main_release
    @token = token

    mail to: user.email, subject: "Version #{release.version} of #{release.app.name} available"
  end

  def added_to_release_group(user, group)
    @user = user
    @group = group

    mail to: user.email, subject: "You've been invited to test #{group.app.name}"
  end
end
