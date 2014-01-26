class AddCategoryToList < ActiveRecord::Migration
  def change
    change_table :lists do |t|
      t.references :category
    end
    add_index :lists, :category_id
  end
end
