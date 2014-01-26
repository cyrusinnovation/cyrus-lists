class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions, :id => false do |t|
      t.references :list
      t.references :subscriber
    end
    add_index :subscriptions, :list_id
    add_index :subscriptions, :subscriber_id
  end
end
