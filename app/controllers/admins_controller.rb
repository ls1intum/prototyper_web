class AdminsController < ApplicationController
  before_action :logged_in_user
  before_action :has_access_to_app,   only: [:destroy, :create]

  def create
    user_id = admin_params[:user_id]
    user = User.find_by(id: user_id)

    unless user.nil?
      @app.admins << user
      if @app.save
        flash[:success] = "Added new developer to app"
        redirect_to "#{app_url(@app)}#user_management"
      else
        flash[:failure] = "Can't add new developer to this app."
        redirect_to "#{app_url(@app)}#user_management"
      end
    end
  end

  def destroy
    @app.admins.delete User.find_by(id: params[:id])
    flash[:success] = "Developer removed"
    redirect_to "#{app_url(@app)}#user_management"
  end

  private

    def admin_params
      params.permit(:user_id)
    end

end
