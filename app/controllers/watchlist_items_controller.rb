class WatchlistItemsController < ApplicationController
  before_action :require_user
  before_action :set_title

  def create
    current_user.watchlist_titles << @title unless current_user.watchlist_titles.exists?(@title.id)
    redirect_back fallback_location: root_path, notice: "«#{@title.name}» добавлен в ваш список."
  end

  def destroy
    current_user.watchlist_items.find_by!(title: @title).destroy!
    redirect_back fallback_location: watchlist_path, notice: "«#{@title.name}» удалён из вашего списка."
  end

  private

  def require_user
    return if current_user

    redirect_to login_path, alert: "Войдите, чтобы пользоваться своим списком."
  end

  def set_title
    @title = Title.find(params[:title_id])
  end
end