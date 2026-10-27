require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires an email in a valid format" do
    user = User.new(username: "viewer", email: "not-an-email", password: "password123")

    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "requires a password of at least eight characters" do
    user = User.new(username: "viewer", email: "viewer@example.com", password: "short")

    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "deletes the user's watchlist items when the account is deleted" do
    assert_difference("WatchlistItem.count", -1) do
      users(:first_user).destroy!
    end
  end
end