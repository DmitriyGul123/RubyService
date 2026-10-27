require "test_helper"

class WatchlistItemTest < ActiveSupport::TestCase
  test "a title can only appear once in a user's watchlist" do
    duplicate = WatchlistItem.new(user: users(:first_user), title: titles(:dune))

    assert_not duplicate.valid?
    assert duplicate.errors[:title_id].any?
  end

  test "different users may save the same title" do
    item = WatchlistItem.new(user: users(:second_user), title: titles(:dune))

    assert item.valid?
  end
end