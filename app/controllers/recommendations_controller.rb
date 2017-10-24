class RecommendationsController < ApplicationController
  before_action :signed_in_user

  def index
    if current_user.reviews.count >= 20
      @recommendations = current_user.recommend_book
    end
  end
end
