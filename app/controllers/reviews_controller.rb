class ReviewsController < ApplicationController
  before_action :signed_in_user

  def index
    @fav_genres = []
    fav_genre_ids = current_user.favorite_genres.pluck(:genre_id).each do |id|
      @fav_genres << Genre.find(id).name
    end

    @other_genres = Genre.where.not(id: fav_genre_ids).pluck(:name)

    genre = Genre.find_by(name: params[:genre])

    if genre
      @genre_books = genre.books.page(params[:page]).per(50)
    else
      @genre_books = Book.where(genre_id: fav_genre_ids[0]).page(params[:page]).per(50)
    end
  end
end
