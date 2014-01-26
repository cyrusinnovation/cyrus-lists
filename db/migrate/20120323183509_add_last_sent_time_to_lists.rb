class AddLastSentTimeToLists < ActiveRecord::Migration
  def change
    add_column :lists, :last_sent_time, :datetime
  end
end
