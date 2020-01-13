class AppsController < ApplicationController
  include AppsHelper

  before_action :logged_in_user, only: [:index, :show, :new, :create, :edit, :update, :destroy, :users_bamboo_plans]
  before_action :has_access_to_app,   only: [:destroy, :show, :edit, :update]
  before_action :has_admin_rights,    only: [:destroy]
  before_action :has_write_permissions, only: [:new, :create]

  def index
    @apps = current_user.administratable_apps.order(created_at: :desc)
    @apps = App.all.order(created_at: :desc) if current_user.admin
  end

  def show
    @releases = Release.where(app_id: @app.id).order(created_at: :desc)
    @admins = @app.admins
    @users = User.all
    if @app.groups.empty?
      @cellWidth = 1
    else
      @cellWidth = (6/@app.groups.length).ceil
    end
  end

  def new
    @app = current_user.apps.build if logged_in?
  end

  def create
    @app = current_user.apps.build(app_params)
    @app.bundle_id = "de.tum.in.www1.#{@app.bundle_id}"
    if @app.save
      current_user.administratable_apps << @app
      flash[:success] = "App added"
      redirect_to app_url(@app)
    else
      render 'new'
    end
  end

  def edit
    @bamboo_projects = bamboo_projects(current_user)
    @bundle_id = @app.bundle_id.gsub("de.tum.in.www1.", "")
  end

  def update
    old_bamboo_project = @app.bamboo_project
    old_bamboo_plan = @app.bamboo_plan

    new_params = app_params

    if current_user.admin
      new_params[:bundle_id] = "de.tum.in.www1.#{app_params[:bundle_id]}"
    end

    if @app.update_attributes(new_params)
      if @app.bamboo_project.blank? && !old_bamboo_project.blank?
        @app.bamboo_project = old_bamboo_project
      end
      if @app.bamboo_plan.blank? && !old_bamboo_plan.blank?
        @app.bamboo_plan = old_bamboo_plan
      end
      @app.save
      flash[:success] = "App updated"
      redirect_to app_url(@app)
    else
      @bamboo_projects = bamboo_projects(current_user)
      render 'edit'
    end
  end

  def destroy
    @app.destroy
    flash[:success] = "App deleted"
    redirect_to apps_url
  end

  def users_bamboo_plans
    project_key = params[:project]
    @bamboo_plans = bamboo_plans(current_user, project_key)
    render :layout => false
  end

  def find_release
    bundle_id = params[:bundle_id]
    bundle_version = params[:bundle_version]

    app = App.find_by(bundle_id: bundle_id)
    build = Build.find_by(bundle_version: bundle_version)

    unless build.nil?
      release = build.release
    end

    if app.nil? && !release.nil?
      app = release.app
    end

    if app.nil? || release.nil?
      render text: "{error: Resource does not exist}", :status => 404
    else
      respond_to do |format|
        format.html { render json: {app_id: app.id, release_id: release.id} }
        format.json { render json: {app_id: app.id, release_id: release.id} }
      end
    end
  end

  def remove_release_from_group
    group = Group.find_by(id: params[:group_id])
    is_main_release = params[:is_main_release]

    if is_main_release == "true"
      group.main_release = nil
    else
      group.second_release = nil
    end

    group.save
    ReleaseLog.create(group: group, release: nil, is_main_release: is_main_release, changelog: nil).save
    render text: "", :status => 200
  end

  private

    def app_params
      params.require(:app).permit(:name, :bundle_id, :icon, :bamboo_project, :bamboo_plan, :description, :icon_cache, :slack_channel, :jira_project_id, :ipad_only)
    end

end
