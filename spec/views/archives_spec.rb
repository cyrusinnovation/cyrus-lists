require 'spec_helper'

describe "archives/index" do
  before do
    @list = FactoryGirl.create(:list)
    assign(:list, @list)
  end

  it "archive view header" do
    render
    rendered.should match(@list.name)
    rendered.should have_css('.loading', text: "Now Loading...")
  end

  it "table has data-url referencing the parent list" do
    render
    rendered.should match("data-list='#{@list.id}'")
  end

end

describe "archives/_archive_emails" do
  before do
    email = {"uid" => 1, "subject" => "Howdy from Texas", "body" => "Look at that body", "from" => "Beth B.", "date" => Date.today}
    @archive_emails = [email]
  end
  it "should show this email archive partial" do
    render :partial => 'archive_emails', :locals => {:archive_emails => @archive_emails}
    rendered.should match("Howdy from Texas")
    rendered.should match("Look at that body")
    rendered.should match("View Message")

  end
end