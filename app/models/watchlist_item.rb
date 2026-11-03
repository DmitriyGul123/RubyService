class WatchlistItem < ApplicationRecord
  belongs_to :user
  belongs_to :title

  validates :title_id, uniqueness: { scope: :user_id }

  after_create :broadcast_watchlist_count
  after_destroy :broadcast_watchlist_count

  private

  def broadcast_watchlist_count
    Turbo::StreamsChannel.broadcast_replace_to user, :watchlist,
      target: "watchlist-count",
      html: ApplicationController.render(
        partial: "shared/watchlist_count",
        locals: { user: user }
      )
  end
end