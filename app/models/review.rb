class Review < ApplicationRecord
  belongs_to :title
  belongs_to :user

  validates :body, presence: true, length: { maximum: 2000 }
  validates :rating, numericality: { only_integer: true, in: 1..10 }
  validates :user_id, uniqueness: { scope: :title_id }
end
