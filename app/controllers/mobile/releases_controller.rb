class Mobile::ReleasesController < ApplicationController
  before_action :log_in_with_token
  before_action :logged_in_user
  before_action :has_access

  def show
    @manifest_url = params[:main_release] == "true" ? @release.builds.first.manifest_url : @release.builds.last.manifest_url
  end

  private

    def has_access
      @app = App.find(params[:app_id])
      @group = @app.groups.find(params[:group_id])
      @release = @app.releases.find(params[:id])
      main_release = params[:main_release] == "true"

      if @group.users.include? current_user
        if @group.main_release != @release && @group.second_release != @release
          if main_release
            if @group.main_release.nil?
              redirect_to mobile_app_url(@app)
            else
              redirect_to mobile_app_release_url(app_id: @app.id, id: @group.main_release.id, group_id: @group.id, main_release: params[:main_release])
            end
          else
            if @group.second_release.nil?
              redirect_to mobile_app_url(@app)
            else
              redirect_to mobile_app_release_url(app_id: @app.id, id: @group.second_release.id, group_id: @group.id, main_release: params[:main_release])
            end
          end
        end
      else
        redirect_to accessible_apps_path
      end
    end
end
