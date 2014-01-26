require 'spec_helper'

describe UsersController do
  it "destroys a user" do
    user = create :user
    uid = user.id
    delete(:destroy, :id => uid)
    User.find_by_id(uid).should be_nil
  end
end
