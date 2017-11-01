class BooksController < ApplicationController
  def index

  end

  def show
    @book = Book.find_by(id: params[:id])
  end
end
