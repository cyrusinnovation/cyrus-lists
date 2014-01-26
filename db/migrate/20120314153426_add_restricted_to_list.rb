class AddRestrictedToList < ActiveRecord::Migration
  def change
    add_column :lists, :restricted, :boolean
  end
end
