class Title < ApplicationRecord
  KINDS = %w[Фильм Сериал Игра].freeze

  has_many :title_genres, dependent: :destroy
  has_many :genres, through: :title_genres

  validates :name, presence: true, uniqueness: { scope: :kind, case_sensitive: false }
  validates :kind, inclusion: { in: KINDS }
  validates :description, presence: true
  validates :release_year, numericality: { only_integer: true, greater_than_or_equal_to: 1888, less_than_or_equal_to: 2100 }
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :poster_url, format: { with: %r{\Ahttps://\S+\z}, message: :invalid }

  scope :by_kind, ->(kind) { where(kind: KINDS.include?(kind) ? kind : nil) }
  scope :search, ->(query) do
    if query.present?
      pattern = "%#{sanitize_sql_like(query.to_s.strip)}%"
      left_joins(:genres).where("titles.name ILIKE :pattern OR titles.description ILIKE :pattern OR genres.name ILIKE :pattern", pattern: pattern).distinct
    end
  end

  def genre_names
    genres.order(:name).pluck(:name)
  end
end