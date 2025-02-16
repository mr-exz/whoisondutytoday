source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.6'
gem 'actionpack', '>= 7.0.8'
gem 'actionview', '>= 7.0.8'
gem 'activerecord', '>= 7.0.8'
gem 'activestorage', '>= 7.0.8'
gem 'activesupport', '>= 7.0.8'
gem 'async-websocket', '~> 0.8.0'
gem 'bigdecimal'
gem 'bootstrap', '~> 5.3.2'
gem 'font-awesome-rails', '>= 4.7.0.8'
gem 'jquery-rails', '>= 4.6.0'
gem 'json'
gem 'mail'
gem 'mutex_m'
gem 'nokogiri', '>= 1.13.10'
gem 'rubocop'
gem 'slack-ruby-bot', '~> 0.16.1'
gem 'stringio', '~> 3.1.1'
gem 'whenever'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.2.0'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '< 2.0.0'
# Use Puma as the app server
gem 'puma', '~> 6.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0', '>= 6.0.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0', '>= 5.0.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.11', '>= 2.11.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rubocop', require: false
  gem 'standard', require: false
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '~> 3.5'
  gem 'web-console', '>= 4.2.1'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 4.1'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.37.1'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper', '>= 2.1.1'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
