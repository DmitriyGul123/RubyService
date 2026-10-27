require "test_helper"

class GenreTest < ActiveSupport::TestCase
  test "requires a name" do
    assert_not Genre.new.valid?
  end

  test "genre name is unique ignoring case" do
    duplicate = Genre.new(name: "ФАНТАСТИКА")

    assert_not duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "genre exposes associated titles" do
    assert_includes genres(:fantasy).titles, titles(:dune)
  end
end