class AddUniqueIndexToReviews < ActiveRecord::Migration[8.1]
  def change
    add_index :reviews, %i[user_id title_id], unique: true unless index_exists?(:reviews, %i[user_id title_id], unique: true)
  end
end
