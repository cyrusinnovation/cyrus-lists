require 'spec_helper'

describe "lists/archives/index" do
  before(:each) do
    set_omniauth
    subscriber = FactoryGirl.create(:subscriber, :email => "bacchus@#{Settings.organization_domain}")
    @list = FactoryGirl.create(:list, :name => 'abcdefg', :subscribers => [subscriber])
    visit root_path
  end

  it "should show you archive emails when you click on the archives button" do
    page.should have_content('abcdefg')
    click_button 'abcdefg-recent'
    page.should have_content('Recent Messages')
  end

end