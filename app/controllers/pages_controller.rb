class PagesController < ApplicationController
  def home
    @watchlist = false
    load_catalog
  end

  def watchlist
    return redirect_to login_path, alert: "Войдите, чтобы открыть свой список." unless current_user

    @watchlist = true
    load_catalog
    @titles = @titles.where(id: current_user.watchlist_titles.ids)
  end

  private

  def load_catalog
    @kind = params[:kind].presence || "Все"
    @genre = params[:genre].to_s
    @query = params[:q].to_s.strip
    kind_filter = { "Фильмы" => "Фильм", "Сериалы" => "Сериал", "Игры" => "Игра" }[@kind]

    @titles = Title.includes(:genres).order(rating: :desc, name: :asc)
    @titles = @titles.by_kind(kind_filter) if kind_filter
    @titles = @titles.joins(:genres).where(genres: { name: @genre }).distinct if @genre.present?
    @titles = @titles.search(@query) if @query.present?
    @genres = Genre.order(:name)
    @watchlist_title_ids = current_user ? current_user.watchlist_titles.ids : []
  end
end