class CreateCatalog < ActiveRecord::Migration[8.1]
  def change
    create_table :genres do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :genres, :name, unique: true

    create_table :titles do |t|
      t.string :name, null: false
      t.string :kind, null: false
      t.text :description, null: false
      t.integer :release_year, null: false
      t.decimal :rating, precision: 3, scale: 1, null: false
      t.string :poster_url, null: false
      t.timestamps
    end
    add_index :titles, %i[name kind], unique: true
    add_index :titles, :kind

    create_table :title_genres do |t|
      t.references :title, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true
      t.timestamps
    end
    add_index :title_genres, %i[title_id genre_id], unique: true
  end
end