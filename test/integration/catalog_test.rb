require "test_helper"

class CatalogTest < ActionDispatch::IntegrationTest
  test "home page renders catalog items and genres" do
    get root_path

    assert_response :success
    assert_select ".title-card", 3
    assert_select ".title-card h3", text: "Дюна: Часть вторая"
  end

  test "filters titles by content kind" do
    get root_path, params: { kind: "Игры" }

    assert_response :success
    assert_select ".title-card", 1
    assert_select ".title-card h3", text: "Hades"
    assert_no_match "Дюна: Часть вторая", response.body
  end

  test "filters titles by genre and search query" do
    get root_path, params: { genre: "Фантастика", q: "Дюна" }

    assert_response :success
    assert_select ".title-card", 1
    assert_select ".title-card h3", text: "Дюна: Часть вторая"
  end
end