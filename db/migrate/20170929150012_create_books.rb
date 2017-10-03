class CreateBooks < ActiveRecord::Migration[5.1]
  def change
    create_table :books do |t|
      t.string :title
      t.text :author
      t.text :description
      t.string :released_date
      t.string :publisher
      t.string :cover_image
      t.string :isbn
      t.references :genre, foreign_key: true

      t.timestamps
    end
  end
end
