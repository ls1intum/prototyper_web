class UsersController < ApplicationController
  include ActionView::Helpers::UrlHelper

  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user,   only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      @user.save
      message = "Please check your email to activate your account. "
      message += "(" + link_to("Send email again", user_send_activation_url(@user)) + ")"

      flash[:info] = message
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to root_url
    else
      render 'edit'
    end
  end

  def send_activation
    user = User.find(params[:user_id])
    user.send_activation_email
    user.save

    message = "Check your email for the activation link. "
    message += "(" + link_to("Send email again", user_send_activation_url(user)) + ")"
    flash[:info] = message

    redirect_to root_url
  end

  def link_bamboo_account
    auth_hash = request.env['omniauth.auth']
    if current_user
      user = current_user
      user.bamboo_token = auth_hash[:credentials][:token]
      user.bamboo_secret = auth_hash[:credentials][:secret]
      if user.save(:validate => false)
        flash[:success] = "Successfully linked bamboo account."
        redirect_to root_url
      else
        flash[:danger] = "Error linking bamboo account. Please try again later."
        redirect_to root_url
      end
    else
      flash[:danger] = "You need to login before linking your bamboo account."
      redirect_to login_url
    end
  end

  def unlink_bamboo_account
    if current_user
      user = current_user
      user.bamboo_token = nil
      user.bamboo_secret = nil
      if user.save(:validate => false)
        flash[:success] = "Successfully unlinked bamboo account."
        redirect_to root_url
      else
        flash[:danger] = "Error unlinking bamboo account. Please try again later."
        redirect_to root_url
      end
    else
      flash[:danger] = "You need to login before linking your bamboo account."
      redirect_to login_url
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    # Before filters

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
end
