require 'spec_helper'
require 'threatinator/feed_runner'

describe Threatinator::FeedRunner do
  let(:feed_runner) { described_class.new(feed, output_formatter) }
  let(:feed) { build(:feed) }
  let(:output_formatter ) { double("formatter") }

  describe "#_init_fetcher" do
    it "should initialize the fetcher" do
      expect(feed.fetcher_class).to receive(:new).with(feed.fetcher_opts)
      feed_runner._init_fetcher()
    end
  end

  describe "#_fetch" do
    it "should call _init_fetcher, and then run #fetch on the fetcher" do
      mock_fetcher = double("fetcher")
      expect(feed_runner).to receive(:_init_fetcher).and_return(mock_fetcher)
      expect(mock_fetcher).to receive(:fetch)
      feed_runner._fetch()
    end
  end

  describe "#_init_parser" do
    it "should initialize the parser with the fetched IO and parser_opts" do
      mock_io = double("fetched_io")
      expect(feed.parser_class).to receive(:new).with(mock_io, feed.parser_opts)
      feed_runner._init_parser(mock_io)
    end
  end

  describe "#run" do
    context "when providing the :io argument" do
      it "should not call _fetch, but initialize the parser with the thing we provided to :io"  do
        mock_io = double("our io")
        mock_parser = double("parser")
        expect(feed_runner).not_to receive(:_fetch)
        expect(feed_runner).to receive(:_init_parser).with(mock_io).and_return(mock_parser)
        expect(mock_parser).to receive(:each)
        feed_runner.run(:io => mock_io)
      end
    end

    it "should fetch the data, initialize and then run the parser" do
      mock_io = double("fetched_io")
      mock_parser = double("parser")
      expect(feed_runner).to receive(:_fetch).and_return(mock_io)
      expect(feed_runner).to receive(:_init_parser).with(mock_io).and_return(mock_parser)
      expect(mock_parser).to receive(:each)
      feed_runner.run
    end
    it "should call the parser_block for each for each message data parsed" do
      mock_io = double("fetched_io")
      mock_parser = double("parser")
      allow(feed_runner).to receive(:_fetch).and_return(mock_io)
      allow(feed_runner).to receive(:_init_parser).with(mock_io).and_return(mock_parser)
      expect(mock_parser).to receive(:each).and_yield("a1", "b1").and_yield("a2", "b2").and_yield("a3", "b3")
      expect(feed.parser_block).to receive(:call).with(kind_of(Proc), "a1", "b1").ordered
      expect(feed.parser_block).to receive(:call).with(kind_of(Proc), "a2", "b2").ordered
      expect(feed.parser_block).to receive(:call).with(kind_of(Proc), "a3", "b3").ordered
      feed_runner.run
    end
    it "should not call the parser_block if the data was filtered" do
      mock_io = double("fetched_io")
      mock_parser = double("parser")
      allow(feed_runner).to receive(:_fetch).and_return(mock_io)
      allow(feed_runner).to receive(:_init_parser).with(mock_io).and_return(mock_parser)
      expect(mock_parser).to receive(:each).and_yield("a1", "b1").and_yield("a2", "b2").and_yield("a3", "b3")


      mock_filter = double("filter")
      feed.filters = [ mock_filter ]
      expect(mock_filter).to receive(:filter?).with("a1", "b1").ordered.and_return(false)
      expect(feed.parser_block).to receive(:call).with(kind_of(Proc), "a1", "b1").ordered

      expect(mock_filter).to receive(:filter?).with("a2", "b2").ordered.and_return(true)
      expect(mock_filter).to receive(:filter?).with("a3", "b3").ordered.and_return(false)
      expect(feed.parser_block).to receive(:call).with(kind_of(Proc), "a3", "b3").ordered

      feed_runner.run
    end
  end
end
