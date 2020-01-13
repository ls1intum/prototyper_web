class GroupsController < ApplicationController
  include GroupsHelper

  before_action :logged_in_user
  before_action :has_access_to_app
  before_action :has_access_to_group,   only: [:destroy, :edit, :update]
  before_action :has_admin_rights, only: [:destroy]

  def new
    @group = @app.groups.build if logged_in?
  end

  def create
    @group = @app.groups.build(group_params)
    if @group.save
      flash[:success] = "Group created"
      redirect_to edit_app_group_path(@app, @group)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @group.update_attributes(group_params)
      flash[:success] = "Group updated"
      redirect_to edit_app_group_url(@app, @group)
    else
      render 'edit'
    end
  end

  def destroy
    @group.destroy
    flash[:success] = "Group deleted"
    redirect_to "#{app_url(@app)}#user_management"
  end

  private

    def group_params
      params.require(:group).permit(:name, :main_release_id, :second_release_id)
    end

end
