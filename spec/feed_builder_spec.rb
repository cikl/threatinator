require 'spec_helper'
require 'threatinator/feed_builder'
require 'threatinator/record'

describe Threatinator::FeedBuilder do
  let (:provider) { 'FakeSecureCo' }
  let (:name) { 'MaliciousDataFeed' }
  let(:builder) { described_class.new }

  context "without having been configured" do
    describe "#build" do
      it "should raise an error" do
        expect { builder.build() }.to raise_error { |error|
          expect(error).to be_kind_of(Threatinator::Exceptions::InvalidAttributeError)
        }
      end
    end
  end

  describe "#filter_whitespace" do
    let(:builder) { build(:feed_builder, :buildable) }

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
            expect(subject.filter?(Threatinator::Record.new("         \t \t "))).to eq(true)
            expect(subject.filter?(Threatinator::Record.new("   gobbledy goo"))).to eq(false)
          end
        end
      end
    end
  end

  describe "#filter_comments" do
    let(:builder) { build(:feed_builder, :buildable) }

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
            expect(subject.filter?(Threatinator::Record.new("# this is a comment"))).to eq(true)
            expect(subject.filter?(Threatinator::Record.new("Not a comment"))).to eq(false)
          end
        end
      end
    end
  end

  describe "#filter" do
    let(:builder) { build(:feed_builder, :buildable) }

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
    let(:builder) { build(:feed_builder, :without_provider) }

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
    let(:builder) { build(:feed_builder, :without_name) }

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
    let(:builder) { build(:feed_builder, :without_fetcher) }

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
    let(:builder) { build(:feed_builder, :without_parser) }

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

  describe "#parse_csv" do
    let(:builder) { build(:feed_builder, :without_parser) }

    it "should return the builder" do
      expect(builder.parse_csv() {}).to eq(builder)
    end

    context "the built feed" do
      let(:parser_block) { lambda { } }
      let(:parser_opts) { { } }
      let(:feed) {
        builder.parse_csv(parser_opts, &parser_block)
        builder.build
      }
      it "#parser_class should be Threatinator::Parsers::CSVParser" do
        expect(feed.parser_class).to eq(Threatinator::Parsers::CSVParser)
      end
      it "#parser_opts should be correct" do
        expect(feed.parser_opts).to eq(parser_opts)
      end
    end
  end

  shared_examples_for "a DSL loader" do
    # Expects :feed_loader as a proc
      let(:feed_string) { 
'provider "provider1"
name "feed1"
fetch_http("https://foobar/feed1.data")

parse_eachline(:separator => "\n") do |builder, line|
end'
      }

    it "should return an instance of Threatinator::FeedBuilder" do
      expect(feed_loader.call(feed_string)).to be_a(Threatinator::FeedBuilder)
    end

    it "should return a builder after parsing" do
      builder = feed_loader.call(feed_string)
      expect(builder).to be_a(Threatinator::FeedBuilder)
      feed = builder.build
      expect(feed.provider).to eq("provider1")
      expect(feed.name).to eq("feed1")
      expect(feed.fetcher_class).to eq(Threatinator::Fetchers::Http)
      expect(feed.parser_class).to eq(Threatinator::Parsers::Getline)
    end
    
    context "when str contains invalid syntax" do
      let(:feed_string) { 'provider "my_provider"
name "my_provider"
foo = 123 456'}

      it "should raise an error on a syntax error" do
        expect {
          feed_loader.call(feed_string)
        }.to raise_error { |e|
          expect(e).to be_a(SyntaxError)
        }
      end
    end

    describe "#build" do
      it "should raise an InvalidAttributeError if the feed is empty" do
        expect { feed_loader.call("").build }.to raise_error { |error|
          expect(error).to be_kind_of(Threatinator::Exceptions::InvalidAttributeError)
        }
      end
      it "should raise a InvalidAttributeError if the feed is missing a provider" do
        feed_string = '
name "feed1"
fetch_http("https://foobar/feed1.data")
parse_eachline(:separator => "\n") {}'
        expect do 
          feed_loader.call(feed_string).build
        end.to raise_error { |e| 
          expect(e).to be_a(Threatinator::Exceptions::InvalidAttributeError)
          expect(e.attribute).to eq(:provider)
        }
      end

      it "should raise a InvalidAttributeError if the feed is missing a name" do
        feed_string = '
provider "provider1"
fetch_http("https://foobar/feed1.data")
parse_eachline(:separator => "\n") {}'
        expect do 
          feed_loader.call(feed_string).build
        end.to raise_error { |e| 
          expect(e).to be_a(Threatinator::Exceptions::InvalidAttributeError)
          expect(e.attribute).to eq(:name)
        }
      end

      it "should raise a InvalidAttributeError if the feed is missing a fetcher statement" do
        feed_string = '
provider "provider1"
name "feed1"
parse_eachline(:separator => "\n") {}'
        expect do 
          feed_loader.call(feed_string).build
        end.to raise_error { |e| 
          expect(e).to be_a(Threatinator::Exceptions::InvalidAttributeError)
          expect(e.attribute).to eq(:fetcher_class)
        }
      end

      it "should raise a InvalidAttributeError if the feed is missing a parser statement" do
        feed_string = '
provider "provider1"
name "feed1"
fetch_http("https://foobar/feed1.data")'
        expect do 
          feed_loader.call(feed_string).build
        end.to raise_error { |e| 
          expect(e).to be_a(Threatinator::Exceptions::InvalidAttributeError)
          expect(e.attribute).to eq(:parser_class)
        }
      end

      context "when configured to fetch a url and parse each line, the feed" do
        let(:url) { "http://foo.com/bar" }
        let(:feed_string) {
          'provider "my_feed_provider"
          name "my_feed_name"

          fetch_http("http://foo.com/bar")

          filter do |line|
            line =~ /Bad stuff/
          end

          filter_whitespace
          filter_comments

          parse_eachline(separator: "\0") do |*args|
            # parsing stuff
          end'
        }
        let(:feed) { feed_loader.call(feed_string).build() }

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

        describe "#filters" do
          subject { feed.filters } 

          it "should have three filters" do
            expect(subject.length).to eq(3)
          end

          describe "filter 1" do
            subject {feed.filters[0]}
            it { should be_a(Threatinator::Filters::Block) }
          end
          describe "filter 2" do
            subject {feed.filters[1]}
            it { should be_a(Threatinator::Filters::Whitespace) }
          end
          describe "filter 3" do
            subject {feed.filters[2] }
            it { should be_a(Threatinator::Filters::Comments) }
          end
        end
      end
    end

  end

  describe :from_string do
    it_should_behave_like "a DSL loader" do
      let(:feed_loader) { lambda { |arg| Threatinator::FeedBuilder.from_string(arg) } }
    end
  end

  describe :from_file do
    before :each do
      @tempdir = Dir.mktmpdir
    end

    after :each do
      FileUtils.remove_entry_secure @tempdir
    end

    it_should_behave_like "a DSL loader" do
      let(:feed_loader) { 
        lambda do |arg| 
          filename = File.join(@tempdir, "file.feed")
          File.open(filename, "w") do |fio|
            fio.write(arg)
          end
          Threatinator::FeedBuilder.from_file(filename)
        end
      }
    end

    let(:feedfile) {File.expand_path("../support/feeds/provider1/feed1.feed", __FILE__)}
    let(:missing_file) {File.expand_path("../support/feeds/provider1/non-existant.feed", __FILE__)}

    it "should return a builder after parsing the file" do
      builder = Threatinator::FeedBuilder.from_file(feedfile)
      expect(builder).to be_a(Threatinator::FeedBuilder)
      feed = builder.build
      expect(feed.provider).to eq("provider1")
      expect(feed.name).to eq("feed1")
    end

    it "should raise Threatinator::Exceptions::FeedFileNotFoundError if the feed file cannot be found" do
      expect {
        Threatinator::FeedBuilder.from_file(missing_file)
      }.to raise_error(Threatinator::Exceptions::FeedFileNotFoundError)
    end

    it "should call from_string(data, filename, lineno)" do
      data = File.read(feedfile)
      expect(Threatinator::FeedBuilder).to receive(:from_string).with(data, feedfile, 0)
      Threatinator::FeedBuilder.from_file(feedfile)
    end

  end

  describe :from_dsl do
    it_should_behave_like "a DSL loader" do
      let(:feed_loader) { 
        lambda do |arg| 
          Threatinator::FeedBuilder.from_dsl do
            eval(arg)
          end
        end
      }
    end


  end
end


