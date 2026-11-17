class ReviewsController < ApplicationController
  before_action :require_user
  before_action :set_title

  def create
    @review = @title.reviews.new(review_params)
    @review.user = current_user
    save_review
  end

  def update
    @review = current_user.reviews.find_by!(title: @title, id: params[:id])
    @review.assign_attributes(review_params)
    save_review
  end

  private

  def save_review
    creating = @review.new_record?

    if @review.save
      notice = creating ? "Отзыв добавлен." : "Отзыв обновлён."
      redirect_to title_path(@title, anchor: "reviews"), notice: notice
    else
      @reviews = @title.reviews.includes(:user).order(created_at: :desc)
      @in_watchlist = current_user.watchlist_titles.exists?(@title.id)
      render "titles/show", status: :unprocessable_content
    end
  end

  def require_user
    return if current_user

    redirect_to login_path, alert: "Войдите, чтобы оставить отзыв."
  end

  def set_title
    @title = Title.includes(:genres).find(params[:title_id])
  end

  def review_params
    params.require(:review).permit(:body, :rating)
  end
end
