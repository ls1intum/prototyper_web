class ReleasesController < ApplicationController
  include ReleasesHelper
  include GroupsHelper
  include SlackHelper

  before_action :logged_in_user, only: [:index, :show, :new_prototype, :new_ipa, :new_beta, :create, :edit, :update, :destroy, :status, :available, :icon, :release_notes, :release_to_group, :report]
  before_action :has_access_to_app, only: [:index, :show, :new_prototype, :new_ipa, :new_beta, :create, :edit, :update, :destroy, :status, :release_notes, :release_to_group, :report]
  before_action :has_access_to_release, only: [:show, :edit, :update, :destroy, :container, :status, :web_container, :release_notes, :release_to_group, :report]
  before_action :has_download_access_to_app, only: [:available]
  before_action :has_admin_rights, only: [:destroy]

  def index
    @prototypes = Prototype.where(app_id: @app.id)
  end

  def show
    @build_key = @release.build_key
    @status_text = status_text
  end

  def new_prototype
    @prototype = @app.releases.build(type: "Prototype")
  end

  def new_ipa
    @ipa = @app.releases.build(type: "Beta")
  end

  def new_beta
    @beta = @app.releases.build(type: "Beta")
    @branches = @app.branches(current_user)
    @builds = @branches.empty? ? Array.new : builds_for_branch(@branches.first[:key])
  end

  def create
    p params
    if !params[:prototype].nil?
      create_prototype
    elsif !params[:beta][:ipa].nil?
      create_ipa
    elsif !params[:beta].nil?
      create_beta
    end
  end

  def destroy
    @release.destroy
    flash[:success] = "Release deleted"
    redirect_to @app
  end

  def container
    folder_path = @release.container_path
    send_zip_of_folder(folder_path)
  end

  def web_container
    prepare_web_container(@release.container_path)
    redirect_to "/#{@release.id}/marvelapp.com/index.html"
  end

  def status
    @build_key = @release.build_key
    @status_text = status_text

    render :layout => false
  end

  def available
    main_releases = Array.new
    second_releases = Array.new
    current_user.groups.each do |group|
      if group.app.id == @app.id
        main_releases.push(group.main_release) unless group.main_release.nil?
        second_releases.push(group.second_release) unless group.second_release.nil?
      end
    end

    respond_to do |format|
      format.html { render json: {main_releases: main_releases, second_releases: second_releases} }
      format.json { render json: {main_releases: main_releases, second_releases: second_releases} }
    end
  end

  def bamboo_builds
    branch_key = params[:branch]
    @builds = builds_for_branch(branch_key)
    render :layout => false
  end

  def icon
    app_id = params[:app_id].nil? ? params[:id] : params[:app_id]
    release_id = params[:release_id].nil? ? params[:id] : params[:release_id]

    @app = App.find_by(id: app_id)
    @release = @app.releases.find_by(id: release_id)

    if @app.nil? || @release.nil?
      render status: :forbidden, text: "Not authorized (release)"
    else
      create_annotated_icon @release
    end
  end

  def release_notes
    render :text => @release.description
  end

  def release_to_group
    group = Group.find_by(id: params[:group_id])
    is_main_release = params[:is_main_release]
    changelog = params[:changelog]
    send_mails = params[:send_mails]

    @release.description = changelog
    @release.save

    if @release.builds.blank?
      render :text => "The current release is still processing. Try again later.", :status => 400
    else
      if is_main_release == "true"
        checkForChanges group, @release, true if send_mails == "true"
        group.main_release = @release
        group.save
        send_new_release_submission_notification(@app, @release, group, current_user)
        ReleaseLog.create(group: group, release: @release, is_main_release: is_main_release, changelog: changelog).save
        render text: "", :status => 200
      else
        if @release.type == "Beta"
          render :text => "Only mockups can be set as additional releases.", :status => 400
        else
          checkForChanges group, @release, false if send_mails == "true"
          group.second_release = @release
          group.save
          send_new_release_submission_notification(@app, @release, group, current_user)
          ReleaseLog.create(group: group, release: @release, is_main_release: is_main_release, changelog: changelog).save
          render text: "", :status => 200
        end
      end
    end
  end

  def report
    unfilteredLogs = @release.releaseLogs
    @releaseLogs = Array.new
    unfilteredLogs.each do |releaseLog|
      unless @releaseLogs.any? {|rl| rl.group.present? && releaseLog.group.present? && rl.group.id == releaseLog.group.id }
        @releaseLogs << releaseLog
      end
    end
  end

  def share_app
    @app = App.find_by(id: params[:app_id])
    @release = Release.find_by(id: params[:release_id])

    share_email = params[:share_email]
    explanation = params[:explanation]
    username = params[:username].nil? ? params[:feedback][:username] : params[:username]

    username = current_user.nil? ? (username.present? ? username : "Anonymous") : current_user.name
    send_new_share_request_notification @app, @release, username, share_email, explanation

    feedback = @release.feedbacks.build
    feedback.user = current_user
    feedback.text = "Please allow #{share_email} to access this app.\n\nDetails: #{explanation}"
    feedback.username = username
    feedback.save

    render :text => "Share successful"
  end

  private

    def prototype_params
      params.require(:prototype).permit(:version, :description, :url, :type, :hide_statusbar)
    end

    def beta_params
      params.require(:beta).permit(:version, :description, :type, :bamboo_branch, :build_key)
    end

    def ipa_params
      params
    end

    def status_text
      if @release.type == "Beta"
        return "Done"
      end

      user = @release.type == "Beta" ? current_user : nil

      if @release.container_path.nil? && @release.type == "Prototype"
        "Downloading prototype..."
      else
        progress = getProgressForBuildKey(@build_key, user)
        return "#{progress}"
      end
    end

    def has_download_access_to_app
      @app = App.find(params[:app_id])
      @groups = current_user.groups.select { |group|
        group.app.id == @app.id
      }
      redirect_to accessible_apps_path if @groups.empty?
    end

    def checkForChanges(group, release, is_main_release)
      if group.main_release_id != release.id && is_main_release
        sendEmailToGroup(group, release, true)
      end

      if group.second_release_id != release.id && !is_main_release
        sendEmailToGroup(group, release, false)
      end
    end

end
