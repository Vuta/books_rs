class CreateGenres < ActiveRecord::Migration[5.1]
  def change
    create_table :genres do |t|
      t.integer :name

      t.timestamps
    end
  end
end
