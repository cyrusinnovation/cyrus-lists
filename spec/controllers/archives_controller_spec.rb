require 'spec_helper'

describe ArchivesController do

  describe "GET index" do
    before do
      @list = FactoryGirl.create(:list)
      get :index, list_id: @list
    end

    it "assigns a list variable" do
      assigns(:list).should == @list
    end
  end

  describe "GET index.js" do
    before do
      @job = stub("job", :meta_id => '1')
      GmailService.stub(:enqueue).and_return(@job)
      @list = FactoryGirl.create(:list)
      get :index, list_id: @list, :format => :js
    end

    it "should kick off a new resque job setting the meta id" do
      assigns(:meta_id).should == @job.meta_id
    end
  end

  describe "GET poll_for_changes" do
    it "redirects if invalid meta_id given" do
      get :poll_for_changes, list_id: "1", meta_id: ""
      response.should redirect_to root_url
      flash.notice.should == "Invalid Path"
    end

    it "returns result into archive email on successful job" do
      Rails.cache.clear # TODO can we organize these tests to make this less hacky?
      FactoryGirl.create(:list, :id => 2)
      job = stub("Job", succeeded?: true, result: "YEYUH")
      GmailService.stub(:get_meta).and_return(job)

      get :poll_for_changes, list_id: "2", meta_id: "winner", :format => :js

      flash.notice.should == "Messages Loaded!"
      assigns(:archive_emails).should == job.result
    end

    it "redirects to home page if request type is html" do
      get :poll_for_changes, list_id: "1", meta_id: "winner", :format => :html

      response.should redirect_to root_url
      flash.notice.should == "Invalid Path"
    end
  end
end
