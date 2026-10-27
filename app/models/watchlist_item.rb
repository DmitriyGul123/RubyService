class WatchlistItem < ApplicationRecord
  belongs_to :user
  belongs_to :title

  validates :title_id, uniqueness: { scope: :user_id }
end