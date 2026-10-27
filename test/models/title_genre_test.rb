require "test_helper"

class TitleGenreTest < ActiveSupport::TestCase
  test "requires both associated records" do
    association = TitleGenre.new

    assert_not association.valid?
    assert association.errors[:title].any?
    assert association.errors[:genre].any?
  end

  test "a title cannot have the same genre twice" do
    association = TitleGenre.new(title: titles(:dune), genre: genres(:fantasy))

    assert_not association.valid?
    assert association.errors[:genre_id].any?
  end
end