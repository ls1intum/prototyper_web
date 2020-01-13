require 'securerandom'

class GroupUsersController < ApplicationController
  before_action :logged_in_user
  before_action :has_access_to_app
  before_action :has_access_to_group

  def create
    @group_user = @group.group_users.build()

    email = params[:group_user][:email]
    user_id = params[:user_id]

    if user_id.present?
      user = User.find_by(id: user_id)
    elsif email.present?
      user = User.find_by(email: email)
    end

    if user.nil? && email.present?
      randomString = SecureRandom.urlsafe_base64(10)
      user = User.create(name: email, email: email,
                      password: randomString, password_confirmation: randomString)
      user.send_activation_email
      user.save
    end

    @group_user.user = user

    begin
      if @group_user.save
        flash[:success] = "Added user to group"
        redirect_to edit_app_group_path(@app, @group)
        ReleaseMailer.added_to_release_group(user, @group).deliver_now
      else
        flash[:danger] = "Could not add user to group"
        redirect_to edit_app_group_path(@app, @group)
      end
    rescue ActiveRecord::RecordNotUnique
      flash[:danger] = "User is already a member of this release group"
      redirect_to edit_app_group_path(@app, @group)
    end
  end

  def destroy
    @group.group_users.find_by(user_id: params[:id]).destroy
    flash[:success] = "User removed from group"
    redirect_to edit_app_group_path(@app, @group)
  end

  private

    def group_user_params
      params.require(:group_user).permit(:email)
    end

end
