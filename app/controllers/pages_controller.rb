class PagesController < ApplicationController
  def home
    @kind = params[:kind].presence || "Все"
    @genre = params[:genre].to_s
    @query = params[:q].to_s.strip
    kind_filter = { "Фильмы" => "Фильм", "Сериалы" => "Сериал", "Игры" => "Игра" }[@kind]

    @titles = Title.includes(:genres).order(rating: :desc, name: :asc)
    @titles = @titles.by_kind(kind_filter) if kind_filter
    @titles = @titles.joins(:genres).where(genres: { name: @genre }).distinct if @genre.present?
    @titles = @titles.search(@query) if @query.present?
    @genres = Genre.order(:name)
  end
end