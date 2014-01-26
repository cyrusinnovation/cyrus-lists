class Category < ActiveRecord::Base

  attr_accessible :name, :position

  validates :name, :length => {:minimum => 1}
  validates_presence_of :position
  validates_uniqueness_of :position
  has_many :lists

  after_initialize :assign_position
  after_destroy :reorder

  def reorder
    Category.where('position >= ?', position).update_all('position = position -1')
  end

  def move_down
    swap_positions position + 1 unless position == Category.count
  end

  def move_up
    swap_positions position - 1 unless position == 1
  end

  def swap_positions new_position
    old_position = position
    swap_with = Category.find_by_position(new_position)

    self.position = Category.count + 1
    self.save!

    swap_with.position = old_position
    swap_with.save!

    self.position = new_position
    self.save!
  end

  private

  def assign_position
    return if self.position
    self.position = Category.count + 1
  end

end
