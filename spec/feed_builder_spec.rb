require 'spec_helper'
require 'threatinator/feed_builder'

describe Threatinator::FeedBuilder do
  let (:provider) { 'FakeSecureCo' }
  let (:name) { 'MaliciousDataFeed' }
  let(:fetcher_io) { double("io") }
  let(:fetcher_class) { FeedSpec::Fetcher }
  let(:fetcher_opts) { { :io => fetcher_io } }
  let(:parser_class) { FeedSpec::Parser }
  let(:parser_opts) { {} }
  let(:parser_block) { lambda {}  }
  let(:builder) { described_class.new }

  context "without having been configured" do
    describe "#build" do
      it "should raise an error" do
        expect { builder.build() }.to raise_error(Virtus::CoercionError)
      end
    end
  end

  describe "#provider" do
    before :each do 
      builder.name name
      builder.parse_eachline do |*args|
      end
      builder.fetch_http("http://foo.com/bar")
    end

    it "should return the builder" do
      expect(builder.provider("asdf")).to eq(builder)
    end

    context "the built feed" do
      let(:feed) {
        builder.provider(provider)
        builder.build
      }
      it "#provider should be correct" do
        expect(feed.provider).to eq(provider)
      end
    end
  end

  describe "#name" do
    before :each do 
      builder.provider provider
      builder.parse_eachline do |*args|
      end
      builder.fetch_http("http://foo.com/bar")
    end

    it "should return the builder" do
      expect(builder.name("asdf")).to eq(builder)
    end

    context "the built feed" do
      let(:feed) {
        builder.name(name)
        builder.build
      }
      it "#name should be correct" do
        expect(feed.name).to eq(name)
      end
    end
  end

  describe "#fetch_http" do
    let(:url) { 'http://foo.com/bar' }
    before :each do 
      builder.name name
      builder.provider provider
      builder.parse_eachline do |*args|
      end
    end

    it "should return the builder" do
      expect(builder.fetch_http('http://foo.bar/')).to eq(builder)
    end

    context "the built feed" do
      let(:feed) {
        builder.fetch_http(url)
        builder.build
      }
      it "#fetcher_class should be Threatinator::Fetchers::Http" do
        expect(feed.fetcher_class).to eq(Threatinator::Fetchers::Http)
      end
      it "#fetcher_opts should be have the URL" do
        expect(feed.fetcher_opts).to eq({ url: url })
      end
    end
  end

  describe "#parse_eachline" do
    before :each do 
      builder.name name
      builder.provider provider
      builder.fetch_http("http://foo.com/bar")
    end

    it "should return the builder" do
      expect(builder.parse_eachline() {}).to eq(builder)
    end

    context "the built feed" do
      let(:parser_block) { lambda { } }
      let(:parser_opts) { { separator: "\n" } }
      let(:feed) {
        builder.parse_eachline(parser_opts, &parser_block)
        builder.build
      }
      it "#parser_class should be Threatinator::Parsers::Getline" do
        expect(feed.parser_class).to eq(Threatinator::Parsers::Getline)
      end
      it "#parser_opts should be correct" do
        expect(feed.parser_opts).to eq(parser_opts)
      end
    end
  end
end


