class UsersController < ApplicationController
  # def new
  #   @user = User.new
  # end

  # def create
  #   @user = User.new(user_params)
  #   if @user.save
  #     sign_in(@user)
  #     if @user.sign_in_count == 1
  #       redirect_to fav_genres_path
  #     else
  #       flash[:success] = "Welcomeeeeeeeeeeeeeee!!"
  #       redirect_to @user
  #     end
  #   else
  #     render :new
  #   end
  # end

  def show
    @user = User.find_by(id: params[:id])
    @rated_books = @user.rated_books.page(params[:page]).per(15)
    unless @user
      flash[:danger] = "The page you was looking for doesn't exist."
      redirect_to root_url
    end
    # binding.pry
  end

  # private

  # def user_params
  #   params.require(:user).permit(:name, :email, :password, :password_confirmation)
  # end
end
