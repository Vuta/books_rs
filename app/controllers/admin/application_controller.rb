class Admin::ApplicationController < ApplicationController
  layout 'admin'

  private

  def admin_authorize
    if !current_user || !current_user.admin?
      flash[:danger] = "Admin Only"
      redirect_to root_url
    end
  end
end
