class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  private

  def signed_in_user
    unless current_user
      flash[:danger] = "Please sign in to continue!"
      redirect_to sign_in_path
    end
  end
end
