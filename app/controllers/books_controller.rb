class BooksController < ApplicationController
  def index
    @popular_books = Book.popular_of_month
  end

  def show
    @book = Book.find_by(id: params[:id])
    unless @book
      flash[:danger] = "The page you was looking for doesn't exsist!"
      redirect_to root_url
    end
  end
end
