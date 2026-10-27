require "test_helper"

class TitleTest < ActiveSupport::TestCase
  test "requires valid catalog fields" do
    title = Title.new

    assert_not title.valid?
    assert_includes title.errors.attribute_names, :name
    assert_includes title.errors.attribute_names, :kind
    assert_includes title.errors.attribute_names, :description
    assert_includes title.errors.attribute_names, :release_year
    assert_includes title.errors.attribute_names, :rating
    assert_includes title.errors.attribute_names, :poster_url
  end

  test "only allows the supported content kinds" do
    title = titles(:dune)
    title.kind = "Книга"

    assert_not title.valid?
    assert title.errors[:kind].any?
  end

  test "validates year and rating ranges" do
    title = titles(:dune)
    title.release_year = 1800
    title.rating = 10.1

    assert_not title.valid?
    assert title.errors[:release_year].any?
    assert title.errors[:rating].any?
  end

  test "requires a secure poster URL" do
    title = titles(:dune)
    title.poster_url = "http://example.com/poster.jpg"

    assert_not title.valid?
    assert title.errors[:poster_url].any?
  end

  test "title name is unique within its kind, ignoring case" do
    duplicate = titles(:dune).dup
    duplicate.name = "ДЮНА: ЧАСТЬ ВТОРАЯ"

    assert_not duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "the same name may exist for a different kind" do
    title = titles(:dune).dup
    title.kind = "Сериал"

    assert title.valid?
  end

  test "kind scope returns only matching titles" do
    assert_equal [titles(:hades)], Title.by_kind("Игра").to_a
  end

  test "kind scope returns no titles for an unknown kind" do
    assert_empty Title.by_kind("Книга")
  end

  test "search matches title description and genre" do
    assert_includes Title.search("Атрейдес"), titles(:dune)
    assert_includes Title.search("Фантастика"), titles(:dune)
  end

  test "genres are associated and destroyed with the title" do
    title = titles(:dune)
    assert_equal %w[Приключение Фантастика], title.genre_names

    assert_difference("TitleGenre.count", -2) do
      title.destroy!
    end
  end
end