class BooksController < ApplicationController
  def index
    @popular_books = Book.popular_of_month
  end

  def show
    @book = Book.find_by(id: params[:id])
  end
end
