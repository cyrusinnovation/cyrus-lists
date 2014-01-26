class AddCreatedByToList < ActiveRecord::Migration
  def change
    change_table :lists do |t|
      t.references :created_by
    end
    add_index :lists, :created_by_id
  end
end
