require 'threatinator/feed'
require 'threatinator/parser'
require 'threatinator/fetcher'

FactoryGirl.define do
  factory :feed, class: Threatinator::Feed do
    provider 'FakeSecureCo'
    name 'MaliciousDataFeed'
    fetcher_class Threatinator::Fetcher
    fetcher_opts { Hash.new }
    parser_class Threatinator::Parser
    parser_opts { Hash.new }
    parser_block { lambda { |*args| } }

    initialize_with { new(attributes) }

  end
end

