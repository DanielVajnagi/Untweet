class SearchController < ApplicationController
  def index
    @query = params[:q]
    @per_page = 20

    if @query.present?
      @results = SearchService.search_all(@query, per_page: @per_page)
      @users = @results[:users]
      @tweets = @results[:tweets]
    else
      @users = []
      @tweets = []
    end

    respond_to do |format|
      format.html
      format.json { render json: { users: @users, tweets: @tweets } }
    end
  end
end