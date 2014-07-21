require 'threatinator/feed_builder'

FactoryGirl.define do
  factory :feed_builder, class: Threatinator::FeedBuilder do
    initialize_with do
      builder = new()
      attributes.each_pair do |sym, val|
        next if val.nil?
        if val.kind_of?(::Proc)
          builder.send(sym, &val)
        else 
          builder.send(sym, val)
        end
      end
      builder
    end

    trait :provider do
      provider 'FakeSecureCo'
    end

    trait :name do
      name 'MaliciousDataFeed'
    end

    trait :http do
      fetch_http "http://foo.com/bar"
    end

    trait :parse_eachline do
      parse_eachline { lambda { |line|  } } 
    end

    trait :without_provider do
      name
      parse_eachline
      http
    end

    trait :without_name do
      provider
      parse_eachline
      http
    end

    trait :without_parser do
      name
      provider
      http
    end

    trait :without_fetcher do
      name
      provider
      parse_eachline
    end

    trait :buildable do
      name
      provider
      parse_eachline
      http
    end
  end
end
