require 'spec_helper'
require 'threatinator/event_builder'

describe Threatinator::EventBuilder do
  let(:feed_provider) { 'my_provider' }
  let(:feed_name) { 'my_feed' }
  let(:event_builder) { described_class.new(feed_provider, feed_name) }
  let(:type) { :c2 }

  before :each do
    event_builder.type = :c2
  end

  describe "#reset" do
    it "resets 'type' to nil" do
      event_builder.type = :c2
      event_builder.reset
      expect {
        event_builder.build
      }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)
    end

    it "resets the fqdns" do
      event_builder.add_fqdn('foo.com')
      event_builder.reset
      event_builder.type = :c2
      event1 = event_builder.build
      expect(event1.fqdns).to be_empty
    end

    it "resets the ipv4s" do
      event_builder.add_ipv4('1.2.3.4')
      event_builder.reset
      event_builder.type = :c2
      event1 = event_builder.build
      expect(event1.ipv4s).to be_empty
    end

    it "does not reset feed_provider or feed_name" do
      event_builder.reset
      event_builder.type = :c2
      event1 = event_builder.build
      expect(event1.feed_provider).to eq('my_provider')
      expect(event1.feed_name).to eq('my_feed')
    end
  end

  describe "#type=(type)" do
    it "sets the 'type' for built events" do
      event1 = event_builder.build
      expect(event1.type).to eq(:c2)
    end
  end
  describe "#add_ipv4(ipv4)" do
    it "adds the provided ipv4s to built events" do
      event_builder.add_ipv4('1.2.3.4')
      event_builder.add_ipv4('8.8.8.8')
      event1 = event_builder.build
      expect(event1.ipv4s).to contain_exactly('1.2.3.4', '8.8.8.8')
    end
  end
  describe "#add_fqdn(fqdn)" do
    it "adds the provided fqdns to built events" do
      event_builder.add_ipv4('google.com')
      event_builder.add_ipv4('yahoo.com')
      event1 = event_builder.build
      expect(event1.ipv4s).to contain_exactly('google.com', 'yahoo.com')
    end
  end

  describe "#build" do
    it "generates a new event with each call" do
      event1 = event_builder.build
      event2 = event_builder.build
      expect(event1).not_to be(event2)
    end

    specify "successively built events will == each other if the builder has not been changed" do
      event_builder.type = :c2
      event_builder.add_ipv4('1.2.3.4')
      event_builder.add_fqdn('foo.com')
      event1 = event_builder.build
      event2 = event_builder.build
      expect(event1).to be == event2
    end


  end
end

