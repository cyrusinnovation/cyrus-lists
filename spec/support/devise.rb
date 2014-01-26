RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
end

def set_omniauth
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:google] = {
    "info" => {
      "email" => "foobar@#{Settings.organization_domain}"
    }
  }
end
