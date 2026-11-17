class TitlesController < ApplicationController
  def show
    @title = Title.includes(:genres).find(params[:id])
    @reviews = @title.reviews.includes(:user).order(created_at: :desc)
    @review = current_user ? current_user.reviews.find_or_initialize_by(title: @title) : @title.reviews.new
    @in_watchlist = current_user&.watchlist_titles&.exists?(@title.id) || false
  end
end
