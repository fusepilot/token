source "http://rubygems.org"

gem "rails", "3.0.10"
gem "capybara", ">= 0.4.0"
gem "sqlite3"
gem "redcarpet"

group :development, :test do
  gem 'rspec'
  gem 'guard-rspec'
  gem 'guard-bundler'
  
  if RUBY_PLATFORM.downcase.include?("darwin")
      gem 'rb-fsevent'
      gem 'growl'
    end
end

gem "rspec-rails", ">= 2.0.0.beta"

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'
