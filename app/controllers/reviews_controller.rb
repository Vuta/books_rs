class ReviewsController < ApplicationController
  before_action :signed_in_user

  def index
    fav_genre_ids = current_user.favorite_genres.pluck(:genre_id)
    @other_genres = Genre.where.not(id: fav_genre_ids)
    @books = []
    fav_genre_ids.each do |genre_id|
      @books << Book.where(genre_id: genre_id)
    end
    # binding.pry
  end
end
