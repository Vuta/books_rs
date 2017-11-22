class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_global_search_var

  protected

  def after_sign_in_path_for(user)
    if user.class == User
      if user.favorite_genres == []
        fav_genres_path
      else
        user_path(user)
      end
    else
      admin_root_path
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :password, :current_password, :avatar])
  end

  def set_global_search_var
    @q = Book.ransack(params[:q])
  end
end
