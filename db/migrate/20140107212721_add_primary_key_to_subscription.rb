class AddPrimaryKeyToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :id, :primary_key
  end
end
