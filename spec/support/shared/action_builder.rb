require 'spec_helper'

shared_examples_for "an action builder" do
  # expects :builder
  # expects :config_hash
  describe "a call to #feed_registry" do
    let(:feed_registry) { double('feed_registry') }
    let(:feed_search_hash) { double('feed search hash') }
    let(:feed_search) { double('feed_search') }

    before :each do
      allow(Threatinator::FeedRegistry).to receive(:build).and_return(feed_registry)
      allow(Threatinator::Config::FeedSearch).to receive(:new).and_return(feed_search)
    end


    context "when config_hash['feed_search'] exists" do
      before :each do
        config_hash['feed_search'] = feed_search_hash
      end

      it "builds a new Threatinator::Config::FeedSearch using config_hash['feed_search']" do
        expect(Threatinator::Config::FeedSearch).to receive(:new).with(feed_search_hash)
        builder.feed_registry
      end
    end
    context "when config_hash['feed_search'] does not exist" do
      before :each do
        config_hash.delete('feed_search')
      end

      it "builds a new Threatinator::Config::FeedSearch using an empty hash" do
        expect(Threatinator::Config::FeedSearch).to receive(:new).with({})
        builder.feed_registry
      end
    end

    it "builds a new feed registry using the config" do
      expect(Threatinator::FeedRegistry).to receive(:build).with(feed_search)
      builder.feed_registry
    end

    it "returns the instance of Threatinator::FeedRegistry" do
      expect(builder.feed_registry).to be(feed_registry)
    end
  end
end
