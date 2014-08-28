# A sample Gemfile
source "https://rubygems.org"

gem 'typhoeus', '~> 0.6'
gem 'nokogiri', '~> 1.6'
gem 'docile', '~> 1.1'
gem 'virtus', '~> 1.0'
gem 'gli', '~> 2.12'

platforms :mingw, :mswin, :ruby do
  gem 'oj', '~> 2.9'
end

group :test do
  gem 'rake'
  gem 'multi_json', '~> 1.10'
  gem 'simplecov', '~> 0.9'
  gem 'simplecov-vim', '= 0.0.1'
  gem 'rspec', '~> 3'
  gem 'rspec-its', '~> 1'
  gem 'webmock', '~> 1'
  gem 'factory_girl', '~> 4'
end

group :development do
  gem 'jeweler', '~> 2'
  gem 'pry', '~> 0.10'
end
