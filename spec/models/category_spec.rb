require 'spec_helper'

describe Category do
  it "requires a name" do
    category = Category.create :name => ''
    category.persisted?.should be_false
  end

  it "has lists" do
    category = FactoryGirl.create(:category)
    list_name = 'test_list'
    FactoryGirl.create(:list, :name => list_name, :category => category)
    category.lists.first.name.should == list_name
  end

  it "automatically assigns a position a position" do
    category = Category.create :name => 'boom'
    category.persisted?.should be_true
  end

  it "has a unique position" do
    Category.create :name => 'boom', :position => 1
    category = Category.create :name => 'boomy', :position => 1
    category.persisted?.should be_false
  end

  it "can create a new Category at the last spot" do
    Category.create :name => 'boom', :position => 2
    category = Category.find_or_create_by name: 'boomy'
    category.position.should == 2
  end

  it "will not create two categories with the same name when automatically incrementing position" do
    Category.create :name => 'boom', :position => 1
    category = Category.find_or_create_by name: 'boomy'
    category.position.should == 2
    category = Category.find_or_create_by name: 'boomy'
    category.position.should == 2
  end

  it "can move a category down in position" do
    first = Category.create :name => 'boom', :position => 1
    second = Category.create :name => 'boomy', :position => 2
    first.move_down
    first.reload.position.should == 2
    second.reload.position.should == 1
  end

  it "can move a category up in position" do
    first = Category.create :name => 'boom', :position => 1
    second = Category.create :name => 'boomy', :position => 2
    second.move_up
    first.reload.position.should == 2
    second.reload.position.should == 1
  end

  it "can not move up if its already at the top" do
    first = Category.create :name => 'boom', :position => 1
    second = Category.create :name => 'boomy', :position => 2
    first.move_up
    first.reload.position.should == 1
  end

  it "can not move down if its already at the bottom" do
    first = Category.create :name => 'boom', :position => 1
    second = Category.create :name => 'boomy', :position => 2
    second.move_down
    second.reload.position.should == 2
  end

  it "reorders other categories after destroy" do
    third = Category.create :name => 'boomy', :position => 3
    first = Category.create :name => 'boom', :position => 1
    second = Category.create :name => 'boomy', :position => 2

    first.destroy

    second.reload.position.should == 1
    third.reload.position.should == 2
  end

end
