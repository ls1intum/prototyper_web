class Mobile::AppsController < ApplicationController
  before_action :logged_in_user
  before_action :has_access

  def show
  end

  private

    def has_access
      @app = App.find(params[:id])
      @groups = current_user.groups.select { |group|
        group.app.id == @app.id
      }
      redirect_to accessible_apps_path if @groups.empty?
    end

end
