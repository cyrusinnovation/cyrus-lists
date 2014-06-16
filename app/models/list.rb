require 'mail'
class List < ActiveRecord::Base

  attr_accessible :name, :description, :category, :created_by, :restricted

  validates_presence_of :name
  validates_uniqueness_of :name

  validates_presence_of :category
  validates_associated :category

  validates_associated :created_by

  has_many :subscriptions, :dependent => :delete_all
  has_many :subscribers, :through => :subscriptions
  belongs_to :category
  belongs_to :created_by, class_name: 'User'

  after_create :send_email_to_newlist, if: Proc.new { |l| l.name != 'newlist' }
  before_save :downcase_name

  scope :sorted, -> { order('name ASC') }

  def contains_outside_email?
    subscribers.any? do |s|
      email_domain = s.email.split(/@/)[1]
      !Settings.organization_domain_aliases.include? email_domain
    end
  end

  def send_email_to_newlist
    NewListMailer.distribute self
  end


  def self.newlist
    announcements = Category.find_or_create_by(name: 'Announcements')
    creation_options = {
        name: 'newlist',
        description: 'Automated new list creation announcements',
        category: announcements,
    }
    List.find_or_create_by(creation_options)
  end

  def append_emails emails
    emails.each do |subscriber_email|
      subscriber = Subscriber.find_or_create_by_email subscriber_email
      add_subscriber(subscriber)
    end
  end

  def add_subscriber subscriber
    self.subscribers << subscriber unless has_subscriber? subscriber
  end

  def unsubscribe(subscriber)
    subscribers.delete(subscriber)
  end

  def has_subscriber? subscriber
    self.subscribers.include? subscriber
  end

  def can_user_modify? user
    !restricted? || has_subscriber?(user.subscriber)
  end

  def can_user_delete? user
    can_user_modify?(user) || subscribers.count == 0
  end

  def update_last_sent_time
    self.last_sent_time = DateTime.now
    self.save!
  end

  def email_addresses
    subscribers.collect do |user|
      user.email
    end
  end

  private

  def downcase_name
    self.name.downcase! unless self.name.blank?
  end

end
