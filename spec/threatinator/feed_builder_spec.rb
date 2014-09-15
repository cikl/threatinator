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

  shared_examples_for "a filter builder" do
    it "should be a Proc" do
      expect(filter_builder).to be_a(::Proc)
    end
    it "should generate a filter when called" do
      expect(filter_builder.call).to respond_to(:filter?)
    end
  end

  shared_examples_for "a decoder builder" do
    it "should be a Proc" do
      expect(decoder_builder).to be_a(::Proc)
    end
    it "should generate a kind of Threatinator::Decoder when called" do
      expect(decoder_builder.call).to be_kind_of Threatinator::Decoder
    end
  end

  shared_examples_for "an alias of #decode_gzip" do
    let(:method_name) { :decode_gzip }
    let(:builder) { build(:feed_builder, :buildable) }
    it "should return the builder" do
      expect(builder.send(method_name)).to eq(builder)
    end

    specify "calling the method should add a decoder_builder proc that generates a Threatinator::Decoders::Gzip" do
      builder.send(method_name)
      feed = builder.build
      expect(feed.decoder_builders.count).to eq(1)
      decoder_builder = feed.decoder_builders.first
      expect(decoder_builder).to be_a(::Proc)
      expect(decoder_builder.call).to be_a(Threatinator::Decoders::Gzip)
    end

    specify "multiple calls should add as many decoder_builders in the built feed" do
      5.times do 
        builder.send(method_name)
      end

      feed = builder.build
      expect(feed.decoder_builders.count).to eq(5)
    end
  end

  describe "#decode_gzip" do
    it_should_behave_like "an alias of #decode_gzip" do
      let(:method_name) { :decode_gzip }
    end
  end

  describe "#extract_gzip" do
    it_should_behave_like "an alias of #decode_gzip" do
      let(:method_name) { :extract_gzip }
    end
  end

  describe "#gunzip" do
    it_should_behave_like "an alias of #decode_gzip" do
      let(:method_name) { :gunzip}
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
      describe "#filter_builders" do
        it "should have one item" do
          expect(feed.filter_builders.length).to eq(1)
        end

        describe "the first item" do
          let(:filter_builder) { feed.filter_builders[0] }
          it_should_behave_like "a filter builder"

          it "should build Threatinator::Filters::Whitespace when called" do
            expect(filter_builder.call).to be_kind_of(Threatinator::Filters::Whitespace)
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
      describe "#filter_builders" do
        it "should have one item" do
          expect(feed.filter_builders.length).to eq(1)
        end

        describe "the first item" do
          let(:filter_builder) { feed.filter_builders[0] }
          it_should_behave_like "a filter builder"
          it "should build a Threatinator::Filters::Comments when called" do
            expect(filter_builder.call).to be_kind_of(Threatinator::Filters::Comments)
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
      describe "#filter_builders" do
        it "should have one item" do
          expect(feed.filter_builders.length).to eq(1)
        end

        describe "the first item" do
          let(:filter_builder) { feed.filter_builders[0] }
          it_should_behave_like "a filter builder"

          it "should build a Threatinator::Filters::Block when called" do
            expect(filter_builder.call).to be_kind_of(Threatinator::Filters::Block)
          end
        end
      end
    end

    context "the built feed, when three filters are specified" do
      let(:feed) {
        builder.filter do |record|
          record.data == "FILTER1"
        end
        builder.filter_comments
        builder.filter_whitespace
        builder.build
      }
      describe "#filter_builders" do
        it "should have three items" do
          expect(feed.filter_builders.length).to eq(3)
        end

        describe "the first filter builder" do
          let(:filter_builder) { feed.filter_builders[0] }
          it_should_behave_like "a filter builder"
          describe "when called" do
            subject {filter_builder.call}
            it { should be_kind_of(Threatinator::Filters::Block) }
            it "should be the first filter we added" do
              expect(subject.filter?(build(:record, data:"FILTER1"))).to  eq(true)
              expect(subject.filter?(build(:record, data:"#comment"))).to eq(false)
              expect(subject.filter?(build(:record, data:"   "))).to      eq(false)
            end
          end

        end

        describe "the second filter builder" do
          let(:filter_builder) { feed.filter_builders[1] }
          it_should_behave_like "a filter builder"
          describe "when called" do
            subject {filter_builder.call}
            it { should be_kind_of(Threatinator::Filters::Comments) }
            it "should be the first filter we added" do
              expect(subject.filter?(build(:record, data:"FILTER1"))).to  eq(false)
              expect(subject.filter?(build(:record, data:"#comment"))).to eq(true)
              expect(subject.filter?(build(:record, data:"   "))).to      eq(false)
            end
          end
        end

        describe "the third filter builder" do
          let(:filter_builder) { feed.filter_builders[2] }
          it_should_behave_like "a filter builder"
          describe "when called" do
            let(:filter) { filter_builder.call }
            subject { filter }
            it { should be_kind_of(Threatinator::Filters::Whitespace) }
            it "should be the first filter we added" do
              expect(subject.filter?(build(:record, data:"FILTER1"))).to  eq(false)
              expect(subject.filter?(build(:record, data:"#comment"))).to eq(false)
              expect(subject.filter?(build(:record, data:"   "))).to      eq(true)
            end
          end
        end

      end
    end

    context "the built feed, when no filters are specified" do
      let(:feed) {
        builder.build
      }
      describe "#filter_builders" do
        it "should have no filter builders" do
          expect(feed.filter_builders.length).to eq(0)
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
      describe "#fetcher_builder" do
        let(:fetcher_builder) { feed.fetcher_builder }
        it "should be a Proc" do
          expect(fetcher_builder).to be_a(::Proc)
        end
        it "should return an instance of Threatinator::Fetchers::Http when called" do
          expect(fetcher_builder.call).to be_a(Threatinator::Fetchers::Http)
        end
        it "should return a brand new instance of a Threatinator::Fetchers::Http with each call" do
          expect(fetcher_builder.call).not_to be(fetcher_builder.call)
        end
        it "should return instances that are eql? to each other" do
          expect(fetcher_builder.call).to eql(fetcher_builder.call)
        end
      end
    end
  end

  shared_examples_for "a parser builder" do
    it "should be a Proc" do
      expect(parser_builder).to be_a(::Proc)
    end
    it "should return a kind of Threatinator::Parser when called" do
      expect(parser_builder.call).to be_a(Threatinator::Parser)
    end
    it "should return a brand new instances of a parser with each call" do
      expect(parser_builder.call).not_to be(parser_builder.call)
    end
    it "should return instances that are eql? to each other" do
      expect(parser_builder.call).to eql(parser_builder.call)
    end
  end

  describe "#parse_xml" do
    let(:builder) { build(:feed_builder, :without_parser) }

    it "should return the builder" do
      expect(builder.parse_xml('/some/path') {}).to eq(builder)
    end

    context "the built feed" do
      let(:parser_block) { lambda { } }
      let(:feed) {
        builder.parse_xml('/some/path', &parser_block)
        builder.build
      }
      describe "#parser_builder" do
        let(:parser_builder) { feed.parser_builder}
        it_should_behave_like "a parser builder"
        it "should return an instance of Threatinator::Parsers::XML::Parser when called" do
          expect(parser_builder.call).to be_a(Threatinator::Parsers::XML::Parser)
        end
      end
    end
  end

  describe "#parse_json" do
    let(:builder) { build(:feed_builder, :without_parser) }

    it "should return the builder" do
      expect(builder.parse_json() {}).to eq(builder)
    end

    context "the built feed" do
      let(:parser_block) { lambda { } }
      let(:feed) {
        builder.parse_json(&parser_block)
        builder.build
      }
      describe "#parser_builder" do
        let(:parser_builder) { feed.parser_builder}
        it_should_behave_like "a parser builder"
        it "should return an instance of Threatinator::Parsers::JSON::Parser when called" do
          expect(parser_builder.call).to be_a(Threatinator::Parsers::JSON::Parser)
        end
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
      let(:feed) {
        builder.parse_eachline(separator: "\n", &parser_block)
        builder.build
      }
      describe "#parser_builder" do
        let(:parser_builder) { feed.parser_builder}
        it_should_behave_like "a parser builder"
        it "should return an instance of Threatinator::Parsers::Getline::Parser when called" do
          expect(parser_builder.call).to be_a(Threatinator::Parsers::Getline::Parser)
        end
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
      let(:feed) {
        builder.parse_csv({}, &parser_block)
        builder.build
      }
      describe "#parser_builder" do
        let(:parser_builder) { feed.parser_builder}
        it_should_behave_like "a parser builder"
        it "should return an instance of Threatinator::Parsers::CSV::Parser when called" do
          expect(parser_builder.call).to be_a(Threatinator::Parsers::CSV::Parser)
        end
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
      expect(feed.parser_builder.call).to eq(Threatinator::Parsers::Getline::Parser.new(separator: "\n"))
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

        it "#parser_builder should generate the proper Threatinator::Parsers::Getline::Parser" do
          expect(feed.parser_builder.call).to eq(Threatinator::Parsers::Getline::Parser.new(separator:"\0"))
        end

        describe "#filter_builders" do
          subject { feed.filter_builders } 

          it "should have three filter builders" do
            expect(subject.length).to eq(3)
          end

          describe "filter 1" do
            subject {feed.filter_builders[0].call}
            it { should be_a(Threatinator::Filters::Block) }
          end
          describe "filter 2" do
            subject {feed.filter_builders[1].call}
            it { should be_a(Threatinator::Filters::Whitespace) }
          end
          describe "filter 3" do
            subject {feed.filter_builders[2].call }
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

    let(:feedfile) {FEED_FIXTURES.join("provider1", "feed1.feed").to_s}
    let(:missing_file) {FEED_FIXTURES.join("provider1","non-existant.feed").to_s}

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


