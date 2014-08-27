# A sample Gemfile
source "https://rubygems.org"

gem 'typhoeus'
gem 'nokogiri'
gem 'addressable'
gem 'docile'
gem 'virtus'
gem 'gli'

platforms :mingw, :mswin, :ruby do
  gem 'oj', '~> 2.9'
end

group :test do
  gem 'rake'
  gem 'multi_json'
  gem 'simplecov', '~> 0.9'
  gem 'simplecov-vim', '= 0.0.1'
  gem 'simplecov-csv'
  gem 'rspec', '~> 3'
  gem 'rspec-its'
  gem 'webmock'
  gem 'factory_girl', '~> 4'
end

group :development do
  gem 'jeweler'
  gem 'pry'
end
