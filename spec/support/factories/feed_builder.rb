require 'threatinator/feed_builder'

FactoryGirl.define do
  factory :feed_builder, class: Threatinator::FeedBuilder do
    provider 'FakeSecureCo'
    name 'MaliciousDataFeed'
    fetch_http "http://foo.com/bar"
    parse_eachline { lambda { |line|  } } 
    
    initialize_with do
      builder = new()
      unless name.nil?
        builder.name name
      end
      unless provider.nil?
        builder.provider provider
      end
      unless parse_eachline.nil?
        builder.parse_eachline(&parse_eachline)
      end
      unless fetch_http.nil?
        builder.fetch_http(fetch_http)
      end
      builder
    end
  end
end
