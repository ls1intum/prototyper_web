# Preview all emails at http://localhost:3000/rails/mailers/release_mailer
class ReleaseMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/release_mailer/new_version_available
  def new_version_available
    user = User.first
    release = Release.last
    group = Group.last
    main_release = true
    ReleaseMailer.new_version_available(user, release, group, main_release)
  end

  # Preview this email at http://localhost:3000/rails/mailers/release_mailer/added_to_release_group
  def added_to_release_group
    user = User.first
    group = Group.last
    ReleaseMailer.added_to_release_group(user, group)
  end

end
