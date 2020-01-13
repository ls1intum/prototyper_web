module GroupsHelper

  def sendEmailToGroup(group, release, main_release)
    group.users.each do |user|
      download_token = DownloadToken.new(release: release, group: group, user: user, isMainRelease: main_release)
      download_token.token = User.new_token
      download_token.update_attribute(:digest,  User.digest(download_token.token))
      download_token.save

      ReleaseMailer.new_version_available(user, release, group, main_release, download_token.token).deliver_now
    end
  end

end
