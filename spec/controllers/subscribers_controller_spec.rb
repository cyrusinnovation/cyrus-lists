require 'spec_helper'

describe SubscribersController do

  describe "GET index" do
    it "assigns all the subscribers for the specified list" do
      list = create(:list_with_one_subscriber)
      get :index, {:list_id => list.id}

      assigns(:subscribers).should eq(list.subscribers.collect {|it| it.email})
    end
  end

end
