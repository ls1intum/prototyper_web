class AccessibleAppsController < ApplicationController
  before_action :logged_in_user

  def index
    @apps = current_user.groups.map { |group| group.app }.uniq
  end

end
