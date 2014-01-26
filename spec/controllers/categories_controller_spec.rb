require 'spec_helper'

describe CategoriesController do

  before :each do
    sign_in FactoryGirl.create(:user)
    @category = FactoryGirl.create(:category, :position => 1)
    @category_second = FactoryGirl.create(:category, :position => 2)
  end

  it "can move a category down" do
    get :reorder_categories, {:direction => 'down', :category_id => @category.id}

    @category.reload.position.should == 2
    @category_second.reload.position.should == 1
  end
  
  it "can move a category up" do
    get :reorder_categories, {:direction => 'up', :category_id => @category_second.id}

    @category.reload.position.should == 2
    @category_second.reload.position.should == 1
  end

end
