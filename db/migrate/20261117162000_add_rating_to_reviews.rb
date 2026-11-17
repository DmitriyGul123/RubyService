class AddRatingToReviews < ActiveRecord::Migration[8.1]
  def change
    add_column :reviews, :rating, :integer, null: false, default: 5 unless column_exists?(:reviews, :rating)
  end
end
