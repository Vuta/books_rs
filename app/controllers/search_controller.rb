class SearchController < ApplicationController
  def index
    if params[:q] && params[:q][:title_or_author_cont] != ""
      @books = @q.result(distinct: true).page(params[:page]).per(30)
    end
  end
end
