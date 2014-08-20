require 'rubygems'
require 'bundler'
Bundler.setup :default, :test

require 'pathname'
SPEC_ROOT = Pathname.new(__FILE__).dirname.expand_path
PROJECT_ROOT =  SPEC_ROOT.join('../').expand_path
SUPPORT_ROOT = SPEC_ROOT.join('support')

FEEDS_ROOT =  PROJECT_ROOT.join('feeds')
FEED_DATA_ROOT =  SPEC_ROOT.join('feeds', 'data')

FIXTURES_ROOT =  SPEC_ROOT.join('fixtures')
PARSER_FIXTURES = FIXTURES_ROOT.join('parsers')
PLUGIN_FIXTURES = FIXTURES_ROOT.join('plugins')
FEED_FIXTURES =   FIXTURES_ROOT.join('feed')

require 'webmock/rspec'
require 'simplecov'
require 'rspec/its'

formatters = [
  SimpleCov::Formatter::HTMLFormatter
]

begin
  require 'simplecov-vim/formatter'
  formatters << SimpleCov::Formatter::VimFormatter
rescue ::LoadError
end

begin
  require 'simplecov-csv'
  formatters << SimpleCov::Formatter::CSVFormatter
rescue ::LoadError
end

SimpleCov.formatters = formatters
SimpleCov.start do
  project_root = RSpec::Core::RubyProject.root
  add_filter PROJECT_ROOT.join('spec').to_s
  add_filter PROJECT_ROOT.join('.gem').to_s
  add_filter PROJECT_ROOT.join('.git').to_s
end 

require 'factory_girl'
Dir.glob(SUPPORT_ROOT.join('**','*.rb')).sort.each { |f| require f}

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include IOHelpers
  config.extend FeedHelpers::FeedHelperMethods, :feed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

