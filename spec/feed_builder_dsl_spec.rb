require 'spec_helper'
require 'threatinator'

describe "Threatinator#build_feed" do
  let (:feed_provider) { 'FakeSecureCo' }
  let (:feed_name) { 'MaliciousDataFeed' }
  let(:builder) { described_class.new }

  context "without having been configured" do
    it "should raise an error" do
        expect { Threatinator.build_feed(feed_provider,feed_name) { } }.to raise_error(Virtus::CoercionError)
    end
  end

  context "having built a feed configured to fetch a url and parse each line, the feed" do
    let(:url) { "http://foo.com/bar" }
    let(:feed) {
      Threatinator.build_feed("my_feed_provider", "my_feed_name") do
        
        fetch_http("http://foo.com/bar")

        parse_eachline(separator: "\0") do |*args|
        end
      end
    }

    it "#provider should be correct" do
      expect(feed.provider).to eq("my_feed_provider")
    end

    it "#name should be correct" do
      expect(feed.name).to eq("my_feed_name")
    end

    it "#fetcher_class should be Threatinator::Fetchers::Http" do
      expect(feed.fetcher_class).to eq(Threatinator::Fetchers::Http)
    end
    it "#fetcher_opts should be have the URL" do
      expect(feed.fetcher_opts).to eq({ url: "http://foo.com/bar" })
    end
    it "#parser_class should be Threatinator::Parsers::Getline" do
      expect(feed.parser_class).to eq(Threatinator::Parsers::Getline)
    end
    it "#parser_opts should be correct" do
      expect(feed.parser_opts).to eq({separator: "\0"})
    end
  end
end



