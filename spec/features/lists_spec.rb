require 'spec_helper'

describe "Lists" do
  describe "GET /lists" do

    before(:each) do
      set_omniauth
      login_as(FactoryGirl.create(:user), scope: :user)
      visit root_path
    end

    it "works!" do
      visit lists_path
      page.status_code.should be(200)
    end

    it "can add users" do
      subscriber = FactoryGirl.create(:subscriber, :email => "bacchus@#{Settings.organization_domain}")

      list = FactoryGirl.create(:list, :subscribers => [subscriber])
      visit edit_list_path(list)
      fill_in "Add someone else to this list", :with => "bacchus2@#{Settings.organization_domain}"
      click_on "Add"

      page.should have_content('2 subscribers')
    end

    it "should order categories by position" do
      FactoryGirl.create(:category, :name => 'Last', :position => 2)
      FactoryGirl.create(:category, :name => 'First', :position => 1)
      visit lists_path

      page.body.index('First').should < page.body.index('Last')
    end

    it "logo links to the home page" do
      visit lists_path
      within('div.logo') do
        find("a").click
      end
      page.current_path.should == root_path
    end

    it "has a togglable checkbox to subscribe and unsubscribe to each list", js: true do
      visit lists_path
      click_link 'New List'
      fill_in 'list_name', with: 'list1'
      fill_in 'list_category', with: 'category'
      fill_in 'list_description', with: 'First list'
      click_button 'Create'

      click_link 'New List'
      fill_in 'list_name', with: 'list2'
      fill_in 'list_category', with: 'category'
      fill_in 'list_description', with: 'Second list'
      click_button 'Create'

      find('#list1-checkbox').should be_checked
      find('#list2-checkbox').should be_checked
      uncheck('list1-checkbox')
      visit root_path
      find('#list1-checkbox').should_not be_checked
      find('#list2-checkbox').should be_checked
    end
  end
end
