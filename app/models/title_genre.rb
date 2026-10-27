class TitleGenre < ApplicationRecord
  belongs_to :title
  belongs_to :genre

  validates :genre_id, uniqueness: { scope: :title_id }
end