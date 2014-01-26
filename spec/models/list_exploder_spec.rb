require 'spec_helper'

describe ListExploder do

  SPEC_DOMAIN = 'listexploderspec.com'
  CATCHALL = "catchall@#{SPEC_DOMAIN}"

  before do
    @exploder = ListExploder.new [SPEC_DOMAIN], CATCHALL
  end

  it "will not send an email to a different domain" do
    create :list_with_one_subscriber, name: 'tilly'
    @exploder.explode(%w(tilly@shmilly.com), 'bob@smith.com').size.should == 0
  end

  it "will send emails to unknown lists to catchall" do
    @exploder.explode(%W(tilly@#{SPEC_DOMAIN}), 'bob@smith.com').should == [CATCHALL]
  end

  it "can explode a list" do
    subscriber = create(:subscriber, :email => 'apple@a.com')
    subscriber2 = create(:subscriber, :email => 'zimbo@z.com')
    list = create(:list, :name => 'test',
                              :subscribers => [subscriber, subscriber2],
                              :category => create(:category, :position => 5))
    @exploder.explode(%W(test@#{SPEC_DOMAIN}), '').sort.should == %W(apple@a.com #{Settings.archive_address} zimbo@z.com)
  end

  it "updates the last sent time when a list is exploded" do
    subscriber = create(:subscriber, :email => 'apple@a.com')
    subscriber2 = create(:subscriber, :email => 'zimbo@z.com')
    list = create(:list, :name => 'test',
                              :subscribers => [subscriber, subscriber2],
                              :category => create(:category, :position => 5))

    list.reload.last_sent_time.should be_nil
    @exploder.explode(%W(test@#{SPEC_DOMAIN}), '')
    list.reload.last_sent_time.should_not be_nil
  end

  it "adds archive group as recipient if list is public" do
    subscriber = create(:subscriber, :email => 'apple@a.com')
    subscriber2 = create(:subscriber, :email => 'zimbo@z.com')
    list = create(:list, :name => 'test',
                              :subscribers => [subscriber, subscriber2],
                              :category => create(:category, :position => 5),
                              :restricted => false)
    @exploder.explode(%W(test@#{SPEC_DOMAIN}), '').sort.should == %W(apple@a.com #{Settings.archive_address} zimbo@z.com)
  end

  it "does not add archive group as recipient if list is restricted" do
    subscriber = create(:subscriber, :email => 'apple@a.com')
    subscriber2 = create(:subscriber, :email => 'zimbo@z.com')
    list = create(:list, :name => 'test',
                              :subscribers => [subscriber, subscriber2],
                              :category => create(:category, :position => 5),
                              :restricted => true)
    @exploder.explode(%W(test@#{SPEC_DOMAIN}), '').sort.should == %w(apple@a.com zimbo@z.com)
  end

  it "can recursively explode a list" do
    subscriber = create(:subscriber, :email => 'apple@a.com')
    subscriber2 = create(:subscriber, :email => 'zimbo@z.com')
    subscriber_list = create(:subscriber, :email => "yummy@#{SPEC_DOMAIN}")

    list = create(:list, :name => 'test',
                                     :subscribers => [subscriber, subscriber_list],
                                     :category => create(:category, :position => 3))
    nested_list = create(:list, :name => 'yummy',
                                            :subscribers => [subscriber, subscriber2],
                                            :category => create(:category, :position => 10))
    @exploder.explode(%W(test@#{SPEC_DOMAIN}), '').sort.should == %W(apple@a.com #{Settings.archive_address} zimbo@z.com)
  end

  it "can recursively explode a list without getting in an infinite loop" do
    subscriber = create(:subscriber, :email => 'apple@a.com')
    subscriber_list = create(:subscriber, :email => "tummy@#{SPEC_DOMAIN}")
    subscriber_list2 = create(:subscriber, :email => "yummy@#{SPEC_DOMAIN}")

    list = create(:list, :name => 'tummy',
                                     :subscribers => [subscriber, subscriber_list2],
                                     :category => create(:category, :position => 10))
    nested_list = create(:list, :name => 'yummy', :subscribers => [subscriber, subscriber_list], :category => create(:category, :position => 3))
    @exploder.explode(%W(tummy@#{SPEC_DOMAIN}), '').should == %W(apple@a.com #{Settings.archive_address})
  end

  it "can explode multiple lists without looping forever" do
    subscriber = create(:subscriber, :email => 'apple@a.com')
    subscriber2 = create(:subscriber, :email => 'fred@f.com')
    subscriber3 = create(:subscriber, :email => 'zimbo@z.com')
    list = create(:list, :name => 'one',
                                     :subscribers => [subscriber, subscriber2],
                                     :category => create(:category, :position => 10))
    list2 = create(:list, :name => 'two',
                                      :subscribers => [subscriber, subscriber3],
                                      :category => create(:category, :position => 3))
    list2_subscriber = create :subscriber, email: "#{list2.name}@#{SPEC_DOMAIN}"
    list.add_subscriber list2_subscriber
    @exploder.explode(%W(one@listexploderspec.com two@#{SPEC_DOMAIN}), '').sort.should =~ %W{apple@a.com fred@f.com #{Settings.archive_address} zimbo@z.com}
  end

  it "should explode a list with an external email address" do
    list_name = "some_list"
    to = "<#{list_name}@#{SPEC_DOMAIN}>"
    outside_list = "someperson@somewhereelse.com"
    original = "laura@ci.com"
    subscriber = create :subscriber, :email => original
    subscriber2 = create :subscriber, :email => "aa@bac.com"
    list = create :list, :name => list_name,
                                     :subscribers => [subscriber, subscriber2],
                                     :category => create(:category, :position => 10)

    explosion = @exploder.explode %W(wil@something.com #{outside_list} #{to}),
                                  outside_list
    explosion.sort.should =~ %W(aa@bac.com #{original} #{Settings.archive_address})
  end

  context "Email addresses" do
    it "will be stripped of extraneous characters" do
      email = "<someemail@somedest.com>"
      @exploder.simplified(email).should eq "someemail@somedest.com"
      email = "Some User <heyhey@yoyo.com>"
      @exploder.simplified(email).should eq "heyhey@yoyo.com"
      email = "haha@baba.com"
      @exploder.simplified(email).should eq "haha@baba.com"
    end

    it "will determine whether an email address is from an accepted domain" do
      email = "one@#{SPEC_DOMAIN}"
      @exploder.internal(email).should eq email
      email = "one@ohnoyoudidnt.com"
      @exploder.internal(email).should be_nil
    end

    it "can tell you if a randomly formatted valid email belongs to us" do
      email = "<one@#{SPEC_DOMAIN}>"
      @exploder.relevant(email).should eq "one@#{SPEC_DOMAIN}"
      email = "Oh dude <two@nothere.com>"
      @exploder.relevant(email).should be_nil
    end

  end

  context "Expanding a list into subscriber emails" do
    it "will expand a list into its subscribers" do
      list_name = 'doh'
      s1 = create :subscriber, :email => 'aaa@bbb.com'
      s2 = create :subscriber, :email => 'bbb@bbb.com'
      s3 = create :subscriber, :email => 'ccc@bbb.com'
      list = create :list, :name => list_name,
                                       :subscribers => [s1, s2, s3],
                                       :category => create(:category, :position => 10)
      actual = @exploder.recipients_for "#{list_name}@#{SPEC_DOMAIN}"
      actual.sort.should eq [s1.email, Settings.archive_address, s2.email, s3.email].sort
    end

    it "will explode the sublists which are subscribers of a top-level list" do
      top = 'top'
      sub = 'sub'
      s1 = create :subscriber, :email => 'aaa@bbb.com'
      s2 = create :subscriber, :email => 'bbb@bbb.com'
      s3 = create :subscriber, :email => 'ccc@bbb.com'
      s4 = create :subscriber, :email => "#{sub}@#{SPEC_DOMAIN}"
      create :list,
                         :name => top,
                         :subscribers => [s1, s4],
                         :category => create(:category, position: 1)
      create :list,
                         :name => sub,
                         :subscribers => [s2, s3],
                         :category => create(:category, :position => 843)
      expected = [s1.email, Settings.archive_address, s2.email, s3.email]
      actual = @exploder.recipients_for "#{top}@#{SPEC_DOMAIN}"
      actual.sort.should eq expected.sort
    end

    it "can remove a sender from exploded lists" do
      top = 'top'
      sub = 'sub'
      s1 = create :subscriber, :email => 'aaa@bbb.com'
      s2 = create :subscriber, :email => 'bbb@bbb.com'
      s3 = create :subscriber, :email => 'ccc@bbb.com'
      s4 = create :subscriber, :email => "#{sub}@#{SPEC_DOMAIN}"
      create :list, :name => top,
                         :subscribers => [s1, s4],
                         :category => create(:category, position: 1)
      create :list,
                         :name => sub,
                         :subscribers => [s2, s3],
                        :category => create(:category, :position => 843)
      destinations = %W(#{top}@#{SPEC_DOMAIN} #{sub}@#{SPEC_DOMAIN})
      expected = [Settings.archive_address, s2.email, s3.email]
      actual = @exploder.explode(destinations, 'aaa@bbb.com')
      actual.sort.should eq expected.sort
    end

  end

end
