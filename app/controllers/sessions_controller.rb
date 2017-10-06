class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email])
    if @user && @user.authenticate(params[:session][:password])
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
    sign_out
    flash[:success] = "You have been signed out!"
    redirect_to root_url
  end
end
