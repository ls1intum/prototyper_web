class SessionsController < ApplicationController
  include UsersHelper
  include ActionView::Helpers::UrlHelper

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  def new
  end

  def create
    username = params[:session][:email]
    password = params[:session][:password]
    if VALID_EMAIL_REGEX.match(username)
      login_with_email(username, password)
    else
      login_with_tum_id(username, password)
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private
    def login_with_email(email, password)
      user = User.find_by(email: email.downcase)
      if user && user.authenticate(password)
        if user.activated?
          params[:session][:remember_me] == '1' ? remember(user) : forget(user)
          log_in user

          respond_to do |format|
            format.html { redirect_back_or root_url }
            format.json { render json: user, :except =>  [:password_digest,
              :password_digest, :remember_digest, :activation_digest, :activated,
              :activated_at, :reset_digest, :reset_sent_at] }
          end
        else
          message = "Account not activated. "
          message += "Check your email for the activation link. "
          message += "(" + link_to("Send email again", user_send_activation_url(user)) + ")"

          respond_to do |format|
            format.html {
              flash[:warning] = message
              redirect_to root_url
            }
            format.json { render :json => {:error => message}, :status => 401 }
          end

        end
      else
        message = "Invalid email/password combination"

        respond_to do |format|
          format.html {
            flash.now[:danger] = message
            render 'new'
          }
          format.json { render :json => {:error => message}, :status => 401 }
        end
      end
    end

    def login_with_tum_id(tum_id, password)
      if check_tum_id_password(tum_id, password)
        user = User.find_by(tum_id: tum_id)
        if user
          user.authenticate_with_tum_id(password)
        else
          user = register_with_tum_id(tum_id, password)
        end

        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        log_in user

        respond_to do |format|
          format.html { redirect_back_or root_url }
          format.json { render json: user, :except =>  [:password_digest,
            :password_digest, :remember_digest, :activation_digest, :activated,
            :activated_at, :reset_digest, :reset_sent_at] }
        end
      else
        message = "Invalid TUM-ID/password combination"

        respond_to do |format|
          format.html {
            flash.now[:danger] = message
            render 'new'
          }
          format.json { render :json => {:error => message}, :status => 401 }
        end
      end
    end
end
