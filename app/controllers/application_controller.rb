class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :null_session
  include SessionsHelper

  # Confirms a logged-in user.
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def log_in_with_token
    unless logged_in?
      app = App.find(params[:app_id])
      group = app.groups.find(params[:group_id])
      release = app.releases.find(params[:id])
      user = User.find_by(email: params[:email])

      download_token = DownloadToken.find_by(release: release, group: group, user: user)
      unless download_token.nil?
        log_in user if BCrypt::Password.new(download_token.digest).is_password?(params[:token])
      end
    end
  end

  def has_access_to_app
    app_id = params[:app_id].nil? ? params[:id] : params[:app_id]
    @app = current_user.administratable_apps.find_by(id: app_id)
    @app = App.find_by(id: app_id) if current_user.admin
    render status: :forbidden, text: "Not authorized (app)" if @app.nil?
  end

  def has_access_to_group
    group_id = params[:group_id].nil? ? params[:id] : params[:group_id]
    @group = @app.groups.find_by(id: group_id)
    render status: :forbidden, text: "Not authorized (group)" if @group.nil?
  end

  def has_access_to_release
    app_id = params[:app_id].nil? ? params[:id] : params[:app_id]
    @app = App.find_by(id: app_id)

    release_id = params[:release_id].nil? ? params[:id] : params[:release_id]
    @release = @app.releases.find_by(id: release_id)
    render status: :forbidden, text: "Not authorized (release)" if @release.nil?
  end

  def has_download_access_to_release
    app_id = params[:app_id].nil? ? params[:id] : params[:app_id]
    release_id = params[:release_id].nil? ? params[:id] : params[:release_id]

    @app = App.find_by(id: app_id)
    @release = @app.releases.find_by(id: release_id)
  end

  def has_admin_rights
    render status: :forbidden, text: "Not authorized" unless current_user.admin
  end

  def has_write_permissions
    if current_user.write_permissions == false && current_user.admin == false
      render status: :forbidden, text: "Not authorized (app)" if @app.nil?
    end
  end

  # Show right error pages

  def local_request?
    false
  end

end
