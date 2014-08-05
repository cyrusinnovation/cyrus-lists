source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '4.0.2'
gem 'jquery-rails', '2.0.3'
gem "haml", "~> 3.1.4"
gem "haml-rails", "~> 0.3.4", :group => :development

gem "devise", "~> 3.2.2"
gem "omniauth-openid", "~> 1.0.1"
gem 'gmail'
gem 'resque', '1.24.1'
gem 'resque-result'
gem 'dalli'
gem 'pg'
gem 'rails_config'

gem 'protected_attributes'

group :assets do
  gem 'sass-rails',   '~> 4.0.0'
  gem 'coffee-rails', '~> 4.0.0'
  gem 'uglifier', '~> 1.2.3'
end

group :development, :test do
  gem "rb-fsevent"
  gem "guard"
  gem "guard-rspec"
  gem "guard-livereload"
  gem "rspec-rails", "~> 2.12.0"
  gem 'sqlite3'
  gem 'simplecov'
  gem 'pry-debugger'
end

group :test do
  gem "factory_girl_rails", "~> 4.3.0"
  gem "email_spec", "~> 1.2.1"
  gem "capybara", '~> 2.0.2'
  gem 'poltergeist'
#  gem "capybara-webkit", '~> 1.0.0'
  gem 'database_cleaner'
end

group :production do
  gem 'thin'
  gem 'newrelic_rpm'
  gem 'memcachier', "~> 0.0.2"
end
