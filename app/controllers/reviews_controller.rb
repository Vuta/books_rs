class ReviewsController < ApplicationController
  before_action :signed_in_user

  def index
    @fav_genres = []
    fav_genre_ids = current_user.favorite_genres.pluck(:genre_id).each do |id|
      @fav_genres << Genre.find(id).name
    end

    @genres = Genre.all
    @other_genres = Genre.where.not(id: fav_genre_ids).pluck(:name)


    @genre_books = []
    @genres.each do |genre|
      @books = Book.where(genre: genre).page(params[:page])
      @genre_books << [genre, @books]
    end
  end
end
