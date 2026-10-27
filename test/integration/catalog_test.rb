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

  test "complete user path registers, filters, saves, signs out, signs in, and removes a title" do
    post users_path, params: {
      user: {
        username: "new_viewer",
        email: "new_viewer@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
    assert_select ".nav-right", /new_viewer/

    get root_path, params: { kind: "Фильмы", genre: "Фантастика", q: "Дюна" }
    assert_response :success
    assert_select ".title-card h3", text: "Дюна: Часть вторая"
    assert_select ".title-card", 1

    assert_difference("WatchlistItem.count", 1) do
      post title_watchlist_path(titles(:dune))
    end
    assert_redirected_to root_path

    get watchlist_path
    assert_response :success
    assert_select ".title-card h3", text: "Дюна: Часть вторая"

    delete logout_path
    assert_redirected_to root_path
    follow_redirect!
    assert_select ".nav-right", /Войти/

    post login_path, params: { email: "new_viewer@example.com", password: "password123" }
    assert_redirected_to root_path
    follow_redirect!
    assert_select ".nav-right", /new_viewer/

    assert_difference("WatchlistItem.count", -1) do
      delete title_watchlist_path(titles(:dune))
    end
    get watchlist_path
    assert_response :success
    assert_select ".title-card", 0
  end

  test "watchlist is isolated between user accounts" do
    post login_path, params: { email: users(:first_user).email, password: "password123" }
    assert_redirected_to root_path
    follow_redirect!
    assert_select ".nav-right", /first_user/

    delete logout_path
    post login_path, params: { email: users(:second_user).email, password: "password123" }
    assert_redirected_to root_path

    get watchlist_path
    assert_response :success
    assert_select ".title-card", 0
  end

  test "invalid login displays an error without authenticating the user" do
    post login_path, params: { email: users(:first_user).email, password: "wrong-password" }

    assert_response :unprocessable_content
    assert_select ".flash.alert", text: /Неверная электронная почта или пароль/
    assert_select ".nav-right", /Войти/
  end

  test "guests are sent to login when opening a watchlist" do
    get watchlist_path

    assert_redirected_to login_path
    follow_redirect!
    assert_response :success
    assert_select ".flash.alert", text: /Войдите, чтобы открыть свой список/
  end
end