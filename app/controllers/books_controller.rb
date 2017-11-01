class BooksController < ApplicationController
  def index
    if params[:q][:title_or_author_cont] != ""
      @books = @q.result(distinct: true).page(params[:page]).per(30)
    end
  end

  def show
    @book = Book.find_by(id: params[:id])
  end
end
