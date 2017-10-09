class GenresController < ApplicationController
  def index
    @genres = Genre.order(:name)
  end

  def show
    @genre = Genre.find_by(id: params[:id])
    @books = Book.where(genre_id: @genre.id)
  end
end
