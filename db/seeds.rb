catalog = [
  { name: "Дюна: Часть вторая", kind: "Фильм", description: "Пол Атрейдес объединяется с фременами.", release_year: 2024, rating: 8.5, poster_url: "https://image.tmdb.org/t/p/w780/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg", genres: ["Фантастика", "Приключение"] },
  { name: "Разделение", kind: "Сериал", description: "Работа и личная жизнь разделены буквально.", release_year: 2022, rating: 8.7, poster_url: "https://images.unsplash.com/photo-1519608487953-e999c86e7455?auto=format&fit=crop&w=700&q=85", genres: ["Триллер", "Фантастика"] },
  { name: "Hades", kind: "Игра", description: "Сын Аида снова и снова бросает вызов подземному миру.", release_year: 2020, rating: 9.1, poster_url: "https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1145360/library_600x900.jpg", genres: ["Экшен", "Приключение"] },
  { name: "Оппенгеймер", kind: "Фильм", description: "История физика, изменившего ход истории.", release_year: 2023, rating: 8.3, poster_url: "https://image.tmdb.org/t/p/w780/ptpr0kGAckfQkJeJIt8st5dglvd.jpg", genres: ["Драма", "История"] },
  { name: "Медведь", kind: "Сериал", description: "Шеф-повар возвращается управлять семейной закусочной.", release_year: 2022, rating: 8.6, poster_url: "https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=700&q=85", genres: ["Драма", "Комедия"] },
  { name: "The Legend of Zelda: Breath of the Wild", kind: "Игра", description: "Большое путешествие по открытому миру Хайрула.", release_year: 2017, rating: 9.7, poster_url: "https://images.igdb.com/igdb/image/upload/t_cover_big/co3p2d.jpg", genres: ["Приключение", "Экшен"] }
]

catalog.each do |attributes|
  genre_names = attributes.fetch(:genres)
  title = Title.find_or_initialize_by(name: attributes[:name], kind: attributes[:kind])
  title.update!(attributes.except(:genres))
  title.genres = genre_names.map { |name| Genre.find_or_create_by!(name: name) }
end
