require 'spec_helper'

describe Subscriber do
  it "requires an email" do
    subscriber = Subscriber.create :email => ''
    subscriber.persisted?.should be_false
  end

  it "has email validation" do
    subscriber = Subscriber.create :email => '@@@'
    subscriber.persisted?.should be_false

    subscriber = Subscriber.create :email => 'a@b.com'
    subscriber.persisted?.should be_true
  end

  describe "uniqueness" do

    before(:each) do
      Subscriber.create :email => 'foo@example.com'
    end

    it "validates uniqueness of email" do
      subscriber = Subscriber.create :email => 'foo@example.com'
      subscriber.should_not be_valid
    end

    it "validates case-insensitive uniqueness of email" do
      subscriber = Subscriber.create :email => "Foo@Example.Com"
      subscriber.should_not be_valid
    end
  end

  describe "subscribing" do
    it "subscribes to list" do
      list = create :list
      subscriber = Subscriber.create :email => "bar@example.com"
      subscriber.subscribe_to(list)
      subscriber.lists.size.should == 1
    end

    it "unsubscribes from list" do
      list = create :list
      subscriber = Subscriber.create :email => "bar@example.com"
      subscriber.subscribe_to(list)
      subscriber.unsubscribe_from(list)
      subscriber.lists.size.should == 0
    end

    it "unsubscribes from all" do
      subscriber = Subscriber.create :email => "bar@examples.com"
      3.times do |i|
        # i + 1000 is a workaround for problems getting position to increment correctly
        subscriber.subscribe_to(create :list,
          category: create(:category, name: "abc", position: i + 1000))
      end
      subscriber.unsubscribe_from_all
      subscriber.reload
      subscriber.lists.size.should == 0
    end

    it "unsubscribes from all when destroyed" do
      subscriber = Subscriber.create email: "foo@example.com"
      subscriber.subscribe_to(create :list)
      s = subscriber.id
      subscriber.destroy
      Subscription.find_by_subscriber_id(s).should be_nil

    end
  end

  describe "find or create" do

    it "creates a new subscriber" do
      subscriber = Subscriber.find_or_create_by_email "foo@example.com"
      subscriber.persisted?.should be_true
    end

    it "finds existing subscriber" do
      s1 = Subscriber.find_or_create_by_email "foo@example.com"
      s2 = Subscriber.find_or_create_by_email "foo@example.com"
      s1.should == s2
    end

    it "finds existing subscriber, case insensitive" do
      s1 = Subscriber.find_or_create_by_email "foo@example.com"
      s2 = Subscriber.find_or_create_by_email "Foo@Example.com"
      s1.should == s2
    end

  end
end
