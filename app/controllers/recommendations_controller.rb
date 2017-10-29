class RecommendationsController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.reviews.count >= 20
      @recommendations = current_user.recommend_book
      @genre_books = Hash.new { |hash, key| hash[key] = [] }
      @recommendations.each do |book|
        @genre_books[book.genre.name].push(book)
      end
      @genre_books = @genre_books.sort_by {|key, value| -value.count }
    end
  end
end
