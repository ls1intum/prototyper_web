class ContainersController < ApplicationController
  include ReleasesHelper

  before_action :logged_in_user, only: [:new, :create, :show, :status, :download]
  before_action :has_access_to_app, only: [:new, :create, :show, :status, :download]

  def new
    @container = Container.new
  end

  def create
    @container = @app.containers.build(container_params)
    Thread.new do
      @container.container_path = createMarvelBundleForContainer(@container)
      @container.save
    end
    if @container.save
      redirect_to app_container_url(@app, @container)
    else
      flash[:error] = "Marvel URL needed to create container."
      render "new_container"
    end
  end

  def show
    @container = @app.containers.find_by(id: params[:id])
  end

  def status
    @container = Container.find_by(id: params[:container_id])
    if @container.nil?
      render :text => "Couldn't download marvel mockup"
    else
      if @container.container_path.present?
        render :text => "<a href='#{app_container_download_url(@app, @container)}' target='_blank'>Download</a>"
      else
        render :text => "Downloading..."
      end
    end
  end

  def download
    @container = Container.find_by(id: params[:container_id])
    folder_path = @container.container_path
    send_zip_of_folder(folder_path)
  end

  private
    def container_params
      params.require(:container).permit(:marvel_url)
    end

end
