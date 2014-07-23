require 'threatinator/feed'
require 'threatinator/parser'
require 'threatinator/fetcher'

FactoryGirl.define do
  factory :feed, class: Threatinator::Feed do
    provider 'FakeSecureCo'
    name 'MaliciousDataFeed'
    fetcher_builder { lambda { Threatinator::Fetcher.new({}) } } 
    parser_builder { lambda { Threatinator::Parser.new({}) } } 
    filter_builders { [] }
    decoder_builders { [] }
    parser_block { lambda { |*args| } }

    initialize_with { new(attributes) }

  end
end

