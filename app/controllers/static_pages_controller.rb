class StaticPagesController < ApplicationController
  include AppsHelper

  before_action :has_admin_rights,    only: [:admin_overview]

  def home
    if logged_in?
      if browser.platform.ios?
        redirect_to accessible_apps_url
      else
        redirect_to apps_url
      end
    else
      redirect_to login_url
    end
  end

  def legal
  end

  def admin_overview
    @apps = App.all
  end

  def error_404
    render status: 404, inline: "Site not found.<br><a href='/'>Go home</a>"
  end

  def install_instructions
  end

end
