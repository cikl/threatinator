require 'spec_helper'
require 'threatinator/feed_builder'

describe Threatinator::FeedBuilder do
  let (:provider) { 'FakeSecureCo' }
  let (:name) { 'MaliciousDataFeed' }
  let(:builder) { described_class.new }

  context "without having been configured" do
    describe "#build" do
      it "should raise an error" do
        expect { builder.build() }.to raise_error(Virtus::CoercionError)
      end
    end
  end

  describe "#filter_whitespace" do
    before :each do 
      builder.name name
      builder.provider provider
      builder.parse_eachline do |*args|
      end
      builder.fetch_http("http://foo.com/bar")
    end

    it "should return the builder" do
      expect(builder.filter_whitespace).to eq(builder)
    end

    context "the built feed" do
      let(:feed) {
        builder.filter_whitespace
        builder.build
      }
      describe "#filters" do
        it "should have one item" do
          expect(feed.filters.length).to eq(1)
        end

        describe "the first item" do
          subject {feed.filters[0]} 
          it { should be_kind_of(Threatinator::Filters::Whitespace) }

          it "should be the first filter we added" do
            expect(subject.filter?("         \t \t ")).to eq(true)
            expect(subject.filter?("   gobbledy goo")).to eq(false)
          end
        end
      end
    end
  end

  describe "#filter_comments" do
    before :each do 
      builder.name name
      builder.provider provider
      builder.parse_eachline do |*args|
      end
      builder.fetch_http("http://foo.com/bar")
    end

    it "should return the builder" do
      expect(builder.filter_comments).to eq(builder)
    end

    context "the built feed" do
      let(:feed) {
        builder.filter_comments
        builder.build
      }
      describe "#filters" do
        it "should have one item" do
          expect(feed.filters.length).to eq(1)
        end

        describe "the first item" do
          subject {feed.filters[0]} 
          it { should be_kind_of(Threatinator::Filters::Comments) }

          it "should be the first filter we added" do
            expect(subject.filter?("# this is a comment")).to eq(true)
            expect(subject.filter?("Not a comment")).to eq(false)
          end
        end
      end
    end
  end

  describe "#filter" do
    before :each do 
      builder.name name
      builder.provider provider
      builder.parse_eachline do |*args|
      end
      builder.fetch_http("http://foo.com/bar")
    end

    it "should return the builder" do
      expect(builder.filter() {  }).to eq(builder)
    end

    context "the built feed, when one filter is specified" do
      let(:feed) {
        builder.filter do |line|
          line == "FILTER1"
        end
        builder.build
      }
      describe "#filters" do
        it "should have one item" do
          expect(feed.filters.length).to eq(1)
        end

        describe "the first item" do
          subject {feed.filters[0]} 
          it { should be_kind_of(Threatinator::Filters::Block) }

          it "should be the first filter we added" do
            expect(subject.filter?("FILTER1")).to eq(true)
            expect(subject.filter?("gobbledy goo")).to eq(false)
          end
        end
      end
    end

    context "the built feed, when three filters are specified" do
      let(:feed) {
        builder.filter do |line|
          line == "FILTER1"
        end
        builder.filter do |line|
          line == "FILTER2"
        end
        builder.filter do |line|
          line == "FILTER3"
        end
        builder.build
      }
      describe "#filters" do
        it "should have one item" do
          expect(feed.filters.length).to eq(3)
        end

        describe "the first filter" do
          subject {feed.filters[0]} 
          it { should be_kind_of(Threatinator::Filters::Block) }

          it "should be the first filter we added" do
            expect(subject.filter?("FILTER1")).to eq(true)
            expect(subject.filter?("FILTER2")).to eq(false)
            expect(subject.filter?("FILTER3")).to eq(false)
          end
        end

        describe "the second filter" do
          subject {feed.filters[1]} 
          it { should be_kind_of(Threatinator::Filters::Block) }

          it "should be the first filter we added" do
            expect(subject.filter?("FILTER1")).to eq(false)
            expect(subject.filter?("FILTER2")).to eq(true)
            expect(subject.filter?("FILTER3")).to eq(false)
          end
        end

        describe "the third filter" do
          subject {feed.filters[2]} 
          it { should be_kind_of(Threatinator::Filters::Block) }

          it "should be the first filter we added" do
            expect(subject.filter?("FILTER1")).to eq(false)
            expect(subject.filter?("FILTER2")).to eq(false)
            expect(subject.filter?("FILTER3")).to eq(true)
          end
        end

      end
    end

    context "the built feed, when no filters are specified" do
      let(:feed) {
        builder.build
      }
      describe "#filters" do
        it "should have no filters" do
          expect(feed.filters.length).to eq(0)
        end
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


