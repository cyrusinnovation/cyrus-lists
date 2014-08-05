require 'spec_helper'

describe "lists/archives/index" do
  before(:each) do
    set_omniauth
    subscriber = FactoryGirl.create(:subscriber, :email => "bacchus@#{Settings.organization_domain}")
    @list = FactoryGirl.create(:list, :name => 'abcdefg', :subscribers => [subscriber])
    visit root_path
  end

  it "should show navigate to the archives page when you click on the archives button" do
    page.should have_content('abcdefg')
    click_button 'abcdefg-recent'
    page.should have_content('Recent Messages')
  end

  it "should not get a 500 when requesting archive emails via ajax" do
    visit "/lists/#{@list.id}/archives.js"
    page.status_code.should_not == 500
  end

end
