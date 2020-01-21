class FeedbacksController < ApplicationController
  include SlackHelper

  before_action :logged_in_user, only: [:index, :new, :destroy, :toggle]
  before_action :has_access_to_app, only: [:index, :destroy, :toggle]
  before_action :has_access_to_release, only: [:index, :destroy, :toggle]
  before_action :has_download_access_to_release, only: [:new]

  def index
    @feedbacks = @release.feedbacks.order(created_at: :desc)
  end

  def new
    @feedback = @release.feedbacks.build
    @feedback.user = current_user
  end

  def create
    @app = App.find_by(id: params[:app_id])
    @release = Release.find_by(id: params[:release_id])
    @feedback = @release.feedbacks.build(feedback_params)
    @feedback.user = current_user

    if @feedback.save
      send_new_feedback_notification(@app, @release, @feedback)
      respond_to do |format|
        format.html {
          flash[:success] = "Feedback submitted"
          redirect_to app_release_url(@app, @release)
        }
        format.json { render json: @feedback }
      end
    else
      respond_to do |format|
        format.html { render 'new' }
        format.json { render json: {:error => @feedback.errors.full_messages} }
      end
    end
  end

  def destroy
    @feedback = @release.feedbacks.find(params[:id])

    @feedback.destroy
    flash[:success] = "App deleted"
    redirect_to app_release_feedbacks_url(@app, @release)
  end

  def toggle
    @feedback = @release.feedbacks.find(params[:feedback_id])
    @feedback.update_attributes(:completed => !@feedback.completed)
    render status: 200, plain: "#{@feedback.completed}"
  end

  private

    def feedback_params
      if request.request_parameters[:feedback]
        params.require(:feedback).merge(request.request_parameters[:feedback]).permit(:title, :text, :screenshot, :username)
      else
        params.require(:feedback).permit(:title, :text, :screenshot, :username)
      end
    end
end
