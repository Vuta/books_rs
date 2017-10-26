class Admin::SessionsController < Admin::ApplicationController
  layout false

  def new
    if current_user
      if current_user.admin?
        flash[:notice] = "You're already signed in"
        redirect_to admin_dashboard_path
      else
        flash[:danger] = "Admin Only"
        redirect_to root_url
      end
    end
  end

  def create
    @user = User.find_by(email: params[:session][:email])

    if @user && @user.authenticate(params[:session][:password]) && @user.admin?
      sign_in(@user)
      flash[:notice] = "Welcome Admin"
      redirect_to admin_dashboard_path
    else
      render :new
    end
  end
end
