class ListsUsers < ActiveRecord::Migration
  def change
    create_table :lists_users, :id => false do |t|
      t.references :list, :null => false
      t.references :user, :null => false
    end

    add_index :lists_users, [:list_id, :user_id], :unique => true
  end
end
