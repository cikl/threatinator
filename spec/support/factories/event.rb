require 'threatinator/event'

FactoryGirl.define do
  factory :event, class: Threatinator::Event do
    feed_name 'my_feed_name'
    feed_provider 'my_provider'
    type :scanning
    ipv4s { [ ] }
    fqdns { [ ] }

    initialize_with { 
      ret = new() 
      ret.feed_name = feed_name
      ret.feed_provider = feed_provider
      ret.type = type
      ipv4s.each do |ipv4|
        ret.add_ipv4(ipv4)
      end
      fqdns.each do |fqdn|
        ret.add_fqdn(fqdn)
      end
      ret
    }
  end
end


