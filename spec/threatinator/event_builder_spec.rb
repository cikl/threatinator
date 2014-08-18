require 'spec_helper'
require 'threatinator/event_builder'

describe Threatinator::EventBuilder do
  let(:feed) { build(:feed, provider: "my_provider", name: "my_feed" ) }
  let(:event_builder) { described_class.new(feed) }
  describe "#create_event" do
    it "should yield an event" do
      expect { |b| event_builder.create_event(&b) }.to yield_with_args(kind_of(Threatinator::Event))
    end

    it "should increment the count each time it has been called" do
      expect(event_builder.count).to eq(0)
      event_builder.create_event { |e| }
      expect(event_builder.count).to eq(1)
      10.times do
        event_builder.create_event { |e| }
      end
      expect(event_builder.count).to eq(11)
    end

    describe "the yielded event" do
      let(:event) { e = nil; event_builder.create_event { |x| e = x }; e }
      specify "#feed_name is set to the feed's provider" do
        expect(event.feed_name).to eq('my_feed')
      end
      specify "#feed_provider is set to the feed's provider" do
        expect(event.feed_provider).to eq('my_provider')
      end
    end
  end
end

