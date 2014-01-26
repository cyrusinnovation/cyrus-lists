class AddSubscriberIdToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.references :subscriber
    end
    add_index :users, :subscriber_id, :unique => true
  end
end
