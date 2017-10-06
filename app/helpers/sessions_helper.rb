module SessionsHelper
  def sign_in(user)
    session[:user_id] = user.id
    user.sign_in_count += 1
    user.save
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def signed_in?
    current_user.present?
  end

  def sign_out
    session.delete(:user_id)
    @current_user = nil
  end
end
