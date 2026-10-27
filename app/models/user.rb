class User < ApplicationRecord
  has_secure_password
  has_many :watchlist_items, dependent: :destroy
  has_many :watchlist_titles, through: :watchlist_items, source: :title

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
end