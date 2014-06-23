require 'spec_helper'
require 'threatinator'

describe Threatinator do
  before :each do
    Threatinator.registry.clear
  end

  describe :registry do
    it "should return a Threatinator::Registry" do
      expect(Threatinator.registry).to be_a(Threatinator::Registry)
    end

    it "should hold any registered feeds" do
      expect(Threatinator.registry.count).to eq(0)
      feed1 = build(:feed, provider: "myprovider1", name: "myfeed1")
      feed2 = build(:feed, provider: "myprovider2", name: "myfeed2")
      Threatinator.register_feed(feed1)
      Threatinator.register_feed(feed2)
      expect(Threatinator.registry.count).to eq(2)
      expect(Threatinator.registry.get("myprovider1", "myfeed1")).to be(feed1)
      expect(Threatinator.registry.get("myprovider2", "myfeed2")).to be(feed2)
    end
  end

  describe :register_feed do
    context "with arguments (provider, name, &block), and provider is a String" do
      it "should return a Threatinator::Feed object representing the feed" do
        feed = Threatinator.register_feed("myprovider", "myfeed") do
          fetch_http("http://foo.com/bar")
          parse_eachline(separator: "\0") do |*args|
            # parsing stuff
          end
        end

        expect(feed).to be_a(Threatinator::Feed)
        expect(feed.provider).to eq("myprovider")
        expect(feed.name).to eq("myfeed")
      end

      it "should raise FeedAlreadyRegisteredError if a feed of the same name has already been registered" do
        Threatinator.register_feed("myprovider", "myfeed") do
          fetch_http("http://foo.com/bar")
          parse_eachline(separator: "\0") do |*args|
            # parsing stuff
          end
        end
        expect {
          Threatinator.register_feed("myprovider", "myfeed") do
            fetch_http("http://foo.com/bar")
            parse_eachline(separator: "\0") do |*args|
              # parsing stuff
            end
          end
        }.to raise_error(Threatinator::Exceptions::FeedAlreadyRegisteredError)
      end
    end

    context "with arguments (feed), and feed is a Threatinator::Feed object" do
      it "should return the Threatinator::Feed object" do
        feed = build(:feed)
        expect(Threatinator.register_feed(feed)).to be(feed)
      end
      it "should raise FeedAlreadyRegisteredError if a feed of the same name has already been registered" do
        feed1 = build(:feed, provider: "myprovider", name: "myfeed")
        feed2 = build(:feed, provider: "myprovider", name: "myfeed")
        Threatinator.register_feed(feed1)
        expect {
          Threatinator.register_feed(feed2)
        }.to raise_error(Threatinator::Exceptions::FeedAlreadyRegisteredError)
      end
      it "should raise FeedAlreadyRegisteredError if the same feed has already been registered" do
        feed = build(:feed, provider: "myprovider", name: "myfeed")
        Threatinator.register_feed(feed)
        expect {
          Threatinator.register_feed(feed)
        }.to raise_error(Threatinator::Exceptions::FeedAlreadyRegisteredError)
      end
    end

    context "when the first argument is neither a String nor Threatinator::Feed" do
      it "should raise an ArgumentError" do
        expect { Threatinator.register_feed(1234) }.to raise_error(ArgumentError)
        expect { Threatinator.register_feed(:asdf, "woo", lambda {}) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#register_feed_from_file" do
    let(:feedfile) {File.expand_path("../support/feeds/provider1/feed1.feed", __FILE__)}
    let(:missing_file) {File.expand_path("../support/feeds/provider1/non-existant.feed", __FILE__)}
    let(:missing_provider) {File.expand_path("../support/bad_feeds/missing_provider.feed", __FILE__)}
    let(:missing_name) {File.expand_path("../support/bad_feeds/missing_name.feed", __FILE__)}
    let(:missing_fetcher) {File.expand_path("../support/bad_feeds/missing_fetcher.feed", __FILE__)}
    let(:missing_parser) {File.expand_path("../support/bad_feeds/missing_parser.feed", __FILE__)}

    it "should return the feed after parsing the file" do
      ret = Threatinator.register_feed_from_file(feedfile)
      expect(ret).to be_a(Threatinator::Feed)
      expect(ret.provider).to eq("provider1")
      expect(ret.name).to eq("feed1")
    end

    it "should have registered the feed" do
      expect(Threatinator.registry.count).to eq(0)
      feed = Threatinator.register_feed_from_file(feedfile)
      expect(Threatinator.registry.count).to eq(1)
      expect(Threatinator.registry.get(feed.provider, feed.name)).to be(feed)
    end

    it "should raise an error if the feed file cannot be found" do
      expect {
        Threatinator.register_feed_from_file(missing_file)
      }.to raise_error(Threatinator::Exceptions::FeedFileNotFoundError)
    end

    it "should raise a InvalidAttributeError if the feed is missing a provider" do
      expect do 
        Threatinator.register_feed_from_file(missing_provider)
      end.to raise_error { |e| 
        expect(e).to be_a(Threatinator::Exceptions::InvalidAttributeError)
        expect(e.attribute).to eq(:provider)
      }
    end

    it "should raise a InvalidAttributeError if the feed is missing a name" do
      expect do 
        Threatinator.register_feed_from_file(missing_name)
      end.to raise_error { |e| 
        expect(e).to be_a(Threatinator::Exceptions::InvalidAttributeError)
        expect(e.attribute).to eq(:name)
      }
    end

    it "should raise a InvalidAttributeError if the feed is missing a fetcher statement" do
      expect do 
        Threatinator.register_feed_from_file(missing_fetcher)
      end.to raise_error { |e| 
        expect(e).to be_a(Threatinator::Exceptions::InvalidAttributeError)
        expect(e.attribute).to eq(:fetcher_class)
      }
    end

    it "should raise a InvalidAttributeError if the feed is missing a parser statement" do
      expect do 
        Threatinator.register_feed_from_file(missing_parser)
      end.to raise_error { |e| 
        expect(e).to be_a(Threatinator::Exceptions::InvalidAttributeError)
        expect(e.attribute).to eq(:parser_class)
      }
    end
  end
end
