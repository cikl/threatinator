require 'threatinator/event'
require 'threatinator/event_builder'

FactoryGirl.define do
  factory :event, class: Threatinator::Event do
    feed_name 'my_feed_name'
    feed_provider 'my_provider'
    type :scanning
    ipv4s { [ ] }
    fqdns { [ ] }
    urls  { [ ] }

    initialize_with { 
      builder = Threatinator::EventBuilder.new(feed_provider, feed_name)
      builder.type = type

      ipv4s.each do |ipv4|
        builder.add_ipv4(ipv4)
      end
      fqdns.each do |fqdn|
        builder.add_fqdn(fqdn)
      end
      urls.each do |url|
        builder.add_url(url)
      end
      builder.build
    }
  end
end


