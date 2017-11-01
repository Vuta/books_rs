class TextReviewsController < ApplicationController
  def new
    @book = Book.find_by(id: params[:book_id])
  end

  def create
    @book = Book.find_by(id: params[:book_id])
    @review = current_user.reviews.find_by(book_id: @book)
    if @review
      @review.update_attribute(:text, params[:review][:text])
      redirect_to @book
    else
      flash.now[:notice] = "Please add a rating for this book"
      render :new
    end
  end
end
