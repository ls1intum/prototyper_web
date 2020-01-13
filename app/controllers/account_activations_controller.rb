class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Account activated! Please set a new password."
      redirect_to edit_user_url(user)
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
