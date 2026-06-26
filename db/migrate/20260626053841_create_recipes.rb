class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.string :title
      t.text :description
      t.integer :servings
      t.integer :prep_time

      t.timestamps
    end
  end
end
