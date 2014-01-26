class Subscriber < ActiveRecord::Base

  attr_accessible :email

  validates_presence_of :email
  validates_format_of :email, :with => /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i
  validates_uniqueness_of :email, :case_sensitive => false

  has_many :subscriptions
  has_many :lists, :through => :subscriptions

  before_destroy :unsubscribe_from_all

  def self.find_or_create_by_email(email)
    where('UPPER(email) = ?', email.upcase).first || create(:email => email)
  end

  def subscribe_to(list)
    list.subscribers << self unless list.has_subscriber?(self)
  end

  def unsubscribe_from(list)
    list.unsubscribe(self)
  end

  def unsubscribe_from_all
    lists.each do |list|
      unsubscribe_from(list)
    end
  end
end
