class PagesController < ApplicationController
  def home
    @titles = [
      { name: "Дюна: Часть вторая", kind: "Фильм", genre: "Фантастика", year: 2024, score: "8.5", image: "https://image.tmdb.org/t/p/w780/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg", tone: "sand", note: "Пол Атрейдес объединяется с фременами" },
      { name: "Разделение", kind: "Сериал", genre: "Триллер", year: 2022, score: "8.7", image: "https://image.tmdb.org/t/p/w780/lFf6LLrQjYldcZItzOkGmMM4pH.jpg", tone: "ice", note: "Работа и личная жизнь разделены буквально" },
      { name: "Hades", kind: "Игра", genre: "Экшен", year: 2020, score: "9.1", image: "https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1145360/library_600x900.jpg", tone: "ember", note: "Сын Аида снова и снова бросает вызов подземному миру" },
      { name: "Оппенгеймер", kind: "Фильм", genre: "Драма", year: 2023, score: "8.3", image: "https://image.tmdb.org/t/p/w780/ptpr0kGAckfQkJeJIt8st5dglvd.jpg", tone: "rose", note: "История физика, изменившего ход истории" },
      { name: "Медведь", kind: "Сериал", genre: "Драма", year: 2022, score: "8.6", image: "https://image.tmdb.org/t/p/w780/sHFlbKS3WLqMnp9t2ghdotnQxRz.jpg", tone: "copper", note: "Шеф-повар возвращается управлять семейной закусочной" },
      { name: "The Legend of Zelda: Breath of the Wild", kind: "Игра", genre: "Приключение", year: 2017, score: "9.7", image: "https://images.igdb.com/igdb/image/upload/t_cover_big/co3p2d.jpg", tone: "dawn", note: "Большое путешествие по открытому миру Хайрула" }
    ]

    @kind = params[:kind].presence || "Все"
    @genre = params[:genre].to_s
    @query = params[:q].to_s.strip
    kind_filter = { "Фильмы" => "Фильм", "Сериалы" => "Сериал", "Игры" => "Игра" }[@kind]
    @titles = @titles.select { |title| title[:kind] == kind_filter } if kind_filter
    @titles = @titles.select { |title| title[:genre] == @genre } if @genre.present?
    @titles = @titles.select { |title| title.values_at(:name, :kind, :genre).any? { |value| value.downcase.include?(@query.downcase) } } if @query.present?
  end
end