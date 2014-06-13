require 'rubygems'
require 'bundler'
Bundler.setup :default, :test

require 'pathname'
SPEC_ROOT = Pathname.new(__FILE__).dirname.expand_path
PROJECT_ROOT =  (SPEC_ROOT + '../').expand_path

require 'webmock/rspec'
require 'simplecov'

SimpleCov.start do
  project_root = RSpec::Core::RubyProject.root
  add_filter PROJECT_ROOT.join('spec').to_s
  add_filter PROJECT_ROOT.join('.gem').to_s
  add_filter PROJECT_ROOT.join('.git').to_s
end 

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Dir["#{SPEC_ROOT.to_s}/support/**/*.rb"].sort.each { |f| require f}
