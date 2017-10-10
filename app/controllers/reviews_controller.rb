class ReviewsController < ApplicationController
  before_action :signed_in_user

  def index
    fav_genre_ids = current_user.favorite_genres.pluck(:genre_id)
    @genres = Genre.all
    @other_genres = Genre.where.not(id: fav_genre_ids)
    @fav_books = []
    fav_genre_ids.each do |genre_id|
      @fav_books << Book.where(genre_id: genre_id)
    end

    @genre_books = []
    @genres.each do |genre|
      @books = Book.where(genre: genre)
      @genre_books << [genre, @books]
    end
  end
end
