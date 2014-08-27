require 'threatinator/feed'
require 'threatinator/parser'
require 'threatinator/fetcher'
require 'threatinator/fetchers/http'

FactoryGirl.define do
  factory :feed, class: Threatinator::Feed do
    sequence(:provider) { |n| "provider_#{n}" }
    sequence(:name) { |n| "name_#{n}" }
    fetcher_builder { lambda { Threatinator::Fetcher.new({}) } } 
    parser_builder { lambda { Threatinator::Parser.new({}) } } 
    filter_builders { [] }
    decoder_builders { [] }
    parser_block { lambda { |*args| } }

    initialize_with { new(attributes) }

    trait :http do
      url { "https://foobar/#{provider}/#{name}.data" }
      fetcher_builder { lambda { Threatinator::Fetchers::Http.new({url: url}) } } 
    end

    trait :mini do
      http
      sequence(:url) { |n| "http://x#{n}" }
      sequence(:provider) { |n| "x#{n}" }
      sequence(:name) { |n| "x#{n}" }
    end
  end

end

