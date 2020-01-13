class DownloadsController < ApplicationController
  before_action :logged_in_user
  before_action :has_access_to_app, only: [:index, :destroy]
  before_action :has_access_to_release, only: [:index, :destroy]
  before_action :has_download_access_to_release, only: [:create]
  before_action :has_admin_rights, only: [:destroy]

  def index
    @downloads = @release.downloads
  end

  def create
    @download = Download.new
    @download.user = current_user
    @download.release_id = params[:release_id]
    if @download.save
      render :text => "Successfully saved download"
    else
      render :text => @download.errors.full_messages.to_s, :status => 400
    end
  end

  def destroy
    @download = @release.downloads.find(params[:id])
    @download.destroy
    flash[:success] = "Download deleted"
    redirect_to app_release_downloads_url(@app, @release)
  end

  private

    def download_params
      params.require(:build).permit(:release_id, :user_id)
    end

end
