class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:google_oauth2]

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :subscriber

  belongs_to :subscriber, :dependent => :destroy

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token['info']
    email = data['email']
    domain = email.split(/@/)[1]
    return nil unless domain == Settings.organization_domain

    subscriber = Subscriber.find_or_create_by_email email
    User.find_or_create_by_email email, {:name => data['name'],
                                         :password => Devise.friendly_token[0,20],
                                         :subscriber => subscriber}
  end

  def self.find_or_create_by_email email, options
    where('UPPER(email) = ?', email.upcase).first || create(options.merge(:email => email))
  end

end
