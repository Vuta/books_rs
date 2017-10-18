class FavoriteGenresController < ApplicationController
  before_action :signed_in_user

  def index
    @genres = Genre.order(:name)
  end

  def create
    genre_ids = []
    if params[:favorites].nil?
      flash[:notice] = "You must select at least one genre to continue"
      redirect_to fav_genres_path
    else
      params[:favorites].each { |key, value| genre_ids << value.to_i if value.to_i > 0 }
      genre_ids.each do |genre_id|
        FavoriteGenre.create(user_id: current_user.id, genre_id: genre_id)
      end
      redirect_to rate_books_path
    end
  end
end
