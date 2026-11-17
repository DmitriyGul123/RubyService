require "test_helper"

class CatalogTest < ActionDispatch::IntegrationTest
  test "home page renders catalog items and genres" do
    get root_path

    assert_response :success
    assert_select ".title-card", 4
    assert_select ".title-card h3", text: "Дюна: Часть вторая"
  end

  test "all catalog cards link to a detail page with reviews" do
    get root_path

    assert_response :success
    assert_select ".title-card a.title-detail-link", 4
    assert_select ".title-card a.title-detail-link[href=?]", title_path(titles(:dune))
    assert_select ".title-card a.title-detail-link[href=?]", title_path(titles(:hades))
    assert_select ".title-card a.title-detail-link[href=?]", title_path(titles(:severance))
    assert_select ".title-card .share-menu", 4
    assert_select ".title-card .share-popover p", text: "Скопировать ссылку в буфер обмена", count: 4
    assert_select ".title-card [data-share-copy]", 4

    get title_path(titles(:dune))

    assert_response :success
    assert_select "h1", text: "Дюна: Часть вторая"
    assert_select ".title-description", text: titles(:dune).description
    assert_select "#reviews"
    assert_select ".review-sign-in"
  end

  test "signed-in users can add reviews to a title" do
    user = User.create!(username: "review_writer", email: "review_writer@example.com", password: "password123")
    log_in_as(user)

    assert_difference("Review.count", 1) do
      post title_reviews_path(titles(:dune)), params: { review: { body: "Сильная история и отличная атмосфера.", rating: 9 } }
    end

    assert_redirected_to title_path(titles(:dune), anchor: "reviews")
    follow_redirect!
    assert_select ".review-card", text: /Сильная история и отличная атмосфера/
  end

  test "review author can update their existing review" do
    user = User.create!(username: "review_editor", email: "review_editor@example.com", password: "password123")
    title = titles(:dune)
    review = user.reviews.create!(title: title, body: "Первый текст.", rating: 7)
    log_in_as(user)

    assert_no_difference("Review.count") do
      patch title_review_path(title, review), params: { review: { body: "Обновлённый текст.", rating: 9 } }
    end

    assert_redirected_to title_path(title, anchor: "reviews")
    assert_equal "Обновлённый текст.", review.reload.body
    assert_equal 9, review.rating
  end

  test "invalid review is shown on the film detail page" do
    user = User.create!(username: "invalid_review_writer", email: "invalid_review_writer@example.com", password: "password123")
    log_in_as(user)
    post title_reviews_path(titles(:dune)), params: { review: { body: " ", rating: 8 } }

    assert_response :unprocessable_content
    assert_select ".form-errors"
    assert_select "form.review-form"
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

  test "film and series cards render their catalog poster URLs" do
    get root_path

    assert_response :success
    assert_select ".title-card img[src=?]", titles(:dune).poster_url
    assert_select ".title-card img[src=?]", titles(:severance).poster_url
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

  test "guest cannot save a title and the item is not created" do
    assert_no_difference("WatchlistItem.count") do
      post title_watchlist_path(titles(:dune))
    end

    assert_redirected_to login_path
  end

  test "saving the same title twice does not create a duplicate" do
    post login_path, params: { email: users(:second_user).email, password: "password123" }
    assert_redirected_to root_path

    assert_difference("WatchlistItem.count", 1) do
      post title_watchlist_path(titles(:dune))
    end

    assert_no_difference("WatchlistItem.count") do
      post title_watchlist_path(titles(:dune))
    end
  end

  test "saving a title responds with a turbo stream and broadcasts the updated count" do
    user = users(:second_user)
    log_in_as(user)

    assert_turbo_stream_broadcasts [user, :watchlist] do
      post title_watchlist_path(titles(:dune)), as: :turbo_stream
    end

    assert_response :success
    assert_turbo_stream action: "replace", target: "watchlist-count"
    assert_turbo_stream action: "replace", target: dom_id(titles(:dune), :watchlist_button)
  end

  test "watchlist buttons opt in to turbo stream requests" do
    log_in_as(users(:second_user))
    get root_path

    assert_response :success
    assert_select "form##{dom_id(titles(:dune), :watchlist_button)}[data-turbo-stream='true']"
  end

  test "removing a title from the watchlist page removes its card without a redirect" do
    user = User.create!(username: "watchlist_ajax_user", email: "watchlist_ajax_user@example.com", password: "password123")
    title = titles(:dune)
    log_in_as(user)
    WatchlistItem.create!(user: user, title: title)

    delete title_watchlist_path(title), params: { from_watchlist: true }, as: :turbo_stream

    assert_response :success
    assert_turbo_stream action: "remove", target: dom_id(title, :watchlist)
  end

  test "catalog filters update the tabs and results in the same frame" do
    get root_path

    assert_response :success
    assert_select "turbo-frame#recommendations"
    assert_select "a.kind-tab[data-turbo-frame='recommendations']"
    assert_select "form[data-turbo-frame='recommendations']"
  end

  test "frame navigation moves the active tab to the selected kind" do
    get root_path, params: { kind: "Игры" }, headers: { "Turbo-Frame" => "recommendations" }

    assert_response :success
    assert_select "a.kind-tab.is-active", count: 1, text: "Игры"
    assert_select "a.kind-tab[aria-current='page']", count: 1, text: "Игры"
  end

  test "another account cannot delete a title from someone else's watchlist" do
    post login_path, params: { email: users(:second_user).email, password: "password123" }
    assert_redirected_to root_path

    assert_no_difference("WatchlistItem.count") do
      delete title_watchlist_path(titles(:dune))
    end

    assert_response :not_found
    assert WatchlistItem.exists?(user: users(:first_user), title: titles(:dune))
  end

  test "catalog cannot be edited because no edit route is exposed" do
    patch "/titles/#{titles(:dune).id}", params: { title: { name: "Подменённое название" } }

    assert_response :not_found
    assert_equal "Дюна: Часть вторая", titles(:dune).reload.name
  end

  private

  def log_in_as(user)
    post login_path, params: { email: user.email, password: "password123" }
    assert_redirected_to root_path
  end
end