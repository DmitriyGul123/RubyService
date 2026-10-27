class CreateWatchlistItems < ActiveRecord::Migration[8.1]
  def change
    create_table :watchlist_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :title, null: false, foreign_key: true
      t.timestamps
    end

    add_index :watchlist_items, %i[user_id title_id], unique: true
  end
end