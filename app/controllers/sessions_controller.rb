class SessionsController < ApplicationController
  def new
    if current_user
      flash[:notice] = "You are already signed in"
      redirect_to root_url
    end
  end

  def create
    @user = User.find_by(email: params[:session][:email])
    if @user && @user.authenticate(params[:session][:password]) && !@user.admin?
      sign_in(@user)
      if @user.sign_in_count == 1
        redirect_to fav_genres_path
      else
        redirect_to @user
      end
    else
      flash.now[:danger] = "Invalid email or password!"
      render :new
    end
  end

  def destroy
    if current_user.admin?
      redirect_to admin_root_url
    else
      redirect_to root_url
    end
    sign_out
    flash[:success] = "You have been signed out!"
  end
end
