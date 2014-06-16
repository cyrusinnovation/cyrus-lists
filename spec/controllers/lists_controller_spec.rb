require 'spec_helper'

describe ListsController do

  def valid_attributes
    {:name => 'sugar', :description => 'boom', :category => 'Bob'}
  end

  context "logged out" do
    it "needs you to be logged in" do
      get :index
      response.should redirect_to(new_user_session_path)
    end
  end

  context "logged in" do
    before :each do
      @user = FactoryGirl.create(:user)
      sign_in @user
      ActionMailer::Base.deliveries = []
    end

    it "can change the description" do
      list = FactoryGirl.create(:list)
      post :change_description, {:list_id => list.id, :description => 'booya'}
      list.reload.description.should == 'booya'
    end

    it "can change the category" do
      list = FactoryGirl.create :list
      post :change_category, {:list_id => list.id, :category => 'Boom!'}
      list.reload.category.name.should == 'Boom!'
    end

    it "will remove a category if there are zero lists left in it" do
      list = FactoryGirl.create(:list)
      expect {
        post :change_category, {:list_id => list.id, :category => 'Boom!'}
      }.to change(Category, :count).by(0)
    end

    describe "subscribers" do
      it "can add a user to a list" do
        list = FactoryGirl.create(:list)
        put :add_current_user, {:list_id => list.id}
        list.reload.subscribers.should include(@user.subscriber)
      end
      
      it "can add a user to a list that is already on the list" do
        list = FactoryGirl.create(:list, :subscribers => [@user.subscriber])

        expect {
          put :add_current_user, {:list_id => list.id}
        }.to change(list.subscribers, :count).by(0)
      end

      it "cannot add a user to a list that is restricted" do
        list = FactoryGirl.create(:list, :restricted => true)
        put :add_current_user, {:list_id => list.id}
        list.reload.subscribers.should_not include(@user.subscriber)
        response.status.should == 403
      end

      it "displays a flash when you add yourself to a list through the newlist email" do
        list = FactoryGirl.create(:list, name: "silly")
        put :add_current_user, {:list_id => list.id}
        flash[:notice].should == "You have been added to the silly list."
      end

      it "can remove a user from a list" do
        list = FactoryGirl.create(:list, :subscribers => [@user.subscriber])
        put :remove_current_user, {:list_id => list.id}
        list.reload.subscribers.should_not include(@user.subscriber)
      end

      it "a user can remove another user from a list" do
        subscriber = FactoryGirl.create(:subscriber, :email => 'sugar@sagar.com')

        list = FactoryGirl.create(:list, :subscribers => [@user.subscriber, subscriber])
        put :remove_subscriber, {:list_id => list.id, :subscriber_id => [subscriber.id]}
        list.reload.subscribers.should_not include(subscriber)
      end

      it "a user can remove multiple users from a list at one time" do
        subscriber = FactoryGirl.create(:subscriber, :email => 'sugar@sagar.com')
        list = FactoryGirl.create(:list, :subscribers => [@user.subscriber, subscriber])
        subscriber_ids = list.subscribers.map(&:id)
        put :remove_subscriber, {:list_id => list.id, :subscriber_id => subscriber_ids }
        list.reload.subscribers.should_not include(subscriber)
        list.reload.subscribers.should_not include(@user.subscriber)

      end

      it "remove subscriber redirects you if you do not supply a valid user to remove" do
        list = FactoryGirl.create :list
        put :remove_subscriber, {:list_id => list.id, :subscriber_id => [""]}
        response.should redirect_to(List)
      end

      it "can add multiple users to a list" do
        list = FactoryGirl.create(:list, :subscribers => [@user.subscriber])
        post :add_subscribers, {:list_id => list.id, :subscribers => "bobby@b.com\nbetty@c.com"}
        list.reload.subscribers.count.should == 3
      end

      it "can add multiple comma separated users to a list" do
        list = FactoryGirl.create(:list, :subscribers => [@user.subscriber])
        post :add_subscribers, {:list_id => list.id, :subscribers => "bobby@b.com,\nbetty@c.com"}
        list.reload.subscribers.count.should == 3
      end

      it "cannot add users to a list if it is restricted and you are not part of it" do
        list = FactoryGirl.create(:list, :restricted => true)
        post :add_subscribers, {:list_id => list.id, :subscribers => "bobby@b.com\nbetty@c.com"}
        list.reload.subscribers.count.should == 0
      end

      it "can add users to a list if it is restricted and you are a part of it" do
        list = FactoryGirl.create(:list, :restricted => true, :subscribers => [@user.subscriber])
        post :add_subscribers, {:list_id => list.id, :subscribers => "bobby@b.com\nbetty@c.com"}
        list.reload.subscribers.count.should == 3
      end

    end

    describe "GET index" do
      it "assigns all categories as @categories" do
        category = FactoryGirl.create(:category)
        get :index, {}
        assigns(:categories).should eq([category])
      end
    end

    describe "GET new" do
      it "assigns a new list as @list" do
        get :new, {}
        assigns(:list).should be_a_new(List)
      end
    end

    describe "GET edit" do
      it "assigns the requested list as @list" do
        list = FactoryGirl.create(:list)
        get :edit, {:id => list.to_param}
        assigns(:list).should eq(list)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "creates a new List" do
          expect {
            post :create, {:list => valid_attributes}
          }.to change(List, :count).by(2)
          List.first.subscribers.should == [@user.subscriber]
        end

        it "must have a category" do
          expect {
            post :create, {:list => {:name => 'sugar', :description => 'boom', :category => ''}}
          }.to change(List, :count).by(0)
        end

        it "redirects to the created list" do
          post :create, {:list => valid_attributes}
          response.should redirect_to(List)
        end
      end

      it "with invalid params" do
        post :create, {:list => {:name => ''}}
        response.should redirect_to(List)
        flash[:alert].should == "There was a problem.  Name can't be blank, Category is invalid."
      end

    end

    describe "DELETE destroy" do
      it "destroys the requested list" do
        list = FactoryGirl.create(:list)
        expect {
          delete :destroy, {:id => list.to_param}
        }.to change(List, :count).by(-1)
      end

      it "redirects to the lists list" do
        list = FactoryGirl.create(:list)
        delete :destroy, {:id => list.to_param}
        response.should redirect_to(lists_url)
      end

      it "will remove categories if there are zero left" do
        list = FactoryGirl.create(:list)
        expect {
          delete :destroy, {:id => list.to_param}
        }.to change(Category, :count).by(-1)
      end

    end


  end
end
