require 'spec_helper'

describe List do

  context 'Validations' do
    it "requires a name" do
      expect {
        FactoryGirl.create :list, :name => ''
      }.to raise_error ActiveRecord::RecordInvalid
    end

    it "requires a category" do
      list = List.create :name => 'baby'
      list.persisted?.should be_false
    end
  end

  context 'Properties and relationships' do
    it "has subscribers" do
      subscriber = FactoryGirl.create(:subscriber)
      list = FactoryGirl.create(:list)
      list.subscribers << subscriber
      list.subscribers.should == [subscriber]
    end

    it "has a category" do
      list = FactoryGirl.create(:list)
      list.category.should_not be_nil
    end

    it "has a created_by field" do
      list = List.create :name => 'Bobby'
      list.persisted?.should be_false
    end

    it "has a last sent email time" do
      list = FactoryGirl.build(:list)
      list.last_sent_time.should == nil
    end
  end

  it "lowercases names" do
    list = FactoryGirl.create :list, :name => 'BObBY'
    list.name.should == 'bobby'
  end

  it "can tell if it has an outside email address" do
    subscriber = FactoryGirl.create(:subscriber, :email => 'bobby@betty.com')
    list = FactoryGirl.create(:list, :subscribers => [subscriber])
    list.contains_outside_email?.should be_true
  end

  it "does not flag other lists as outside email addresses" do
    inside_email = FactoryGirl.create(:subscriber, :email => "on_the_inside@#{Settings.organization_domain}")
    other_list = FactoryGirl.create(:subscriber, :email => "just_a_list@#{Settings.domain}")
    list = FactoryGirl.create(:list, :subscribers => [inside_email, other_list])
    list.contains_outside_email?.should be_false
  end

  it "can append subscribers from a text input" do
    list = FactoryGirl.create(:list)
    list.append_emails %w(a@b.com c@d.com)
    list.subscribers.size.should == 2
  end

  it "can unsubscribe a subscriber" do
    list = FactoryGirl.create(:list)
    list.append_emails %w(a@b.com c@d.com)
    list.unsubscribe(list.subscribers[0])
    list.subscribers.size.should == 1
  end    

  it "should create the newlist if it's not there" do
    List.destroy_all
    List.newlist
    List.find_by_name('newlist').should_not be_nil
  end

  it "can tell if a user can modify a list" do
    user = FactoryGirl.create(:user)
    list = FactoryGirl.create(:list, :restricted => true, :subscribers => [user.subscriber])
    list.can_user_modify?(user).should be_true
  end

  it "can tell if a user can not modify a list" do
    user = FactoryGirl.create(:user)
    list = FactoryGirl.create(:list, :restricted => true, :subscribers => [])
    list.can_user_modify?(user).should be_false
  end

  it "can tell if a user can delete a list" do
    user = FactoryGirl.create(:user)
    list = FactoryGirl.create(:list, :restricted => true, :subscribers => [user.subscriber])
    list.can_user_delete?(user).should be_true
  end

  it "can tell if a user can delete a list" do
    user = FactoryGirl.create(:user)
    list = FactoryGirl.create(:list, :restricted => true, :subscribers => [])
    list.can_user_delete?(user).should be_true
  end

  it "can tell if a user can not delete a list" do
    user = FactoryGirl.create(:user)
    another_user = FactoryGirl.create(:user)
    list = FactoryGirl.create(:list, :restricted => true, :subscribers => [another_user.subscriber])
    list.can_user_delete?(user).should be_false
  end



  it "can update last sent email time" do
    list = FactoryGirl.create(:list)
    list.update_last_sent_time
    list.last_sent_time.should_not be_nil
  end

  it "will not add duplicate subscribers" do
    subscriber = FactoryGirl.create(:subscriber)

    list = FactoryGirl.create(:list, :subscribers => [subscriber])
    list.add_subscriber(subscriber)
    list.subscribers.size.should == 1
  end

  it 'destroys associated subscriptions when it is destroyed' do
    subscriber = FactoryGirl.create :subscriber
    list = FactoryGirl.create :list, subscribers: [subscriber]
    expect { list.destroy }.to change(Subscription, :count).by(-1)
  end

  context "Scopes" do
    it "gives me a sorted array of lists" do
      category = FactoryGirl.build :category, :name => 'heyo'
      newlist = List.newlist
      list1 = FactoryGirl.create :list, :name => 'list200', :category => category
      list2 = FactoryGirl.create :list, :name => 'mist1', :category => category
      list3 = FactoryGirl.create :list, :name => 'gist1', :category => category

      sorted_list_names = [list1, list2, list3, newlist].sort_by(&:name).map(&:name)
      List.sorted.map(&:name).should eq sorted_list_names
    end
  end

end
