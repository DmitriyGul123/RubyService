class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    unless table_exists?(:reviews)
      create_table :reviews do |t|
        t.references :title, null: false, foreign_key: true
        t.references :user, null: false, foreign_key: true
        t.text :body, null: false
        t.integer :rating, null: false, default: 5
        t.timestamps
      end
    end

    add_foreign_key :reviews, :titles unless foreign_key_exists?(:reviews, :titles)
    add_foreign_key :reviews, :users unless foreign_key_exists?(:reviews, :users)
  end
end
