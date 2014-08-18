require 'spec_helper'
require 'threatinator/feed_runner'

describe Threatinator::FeedRunner do
  let(:output_formatter ) { double("formatter") }
  let(:fetcher) { double("fetcher") }
  let(:fetcher_builder) { lambda { fetcher } }

  let(:io) { double("io") }
  let(:parser) { double("parser") }
  let(:parser_builder) { lambda { parser} }

  let(:filter_builders) { [] }
  let(:decoder_builders) { [] }

  let(:feed) {
    build(:feed, fetcher_builder: fetcher_builder, 
          parser_builder: parser_builder, filter_builders: filter_builders,
          decoder_builders: decoder_builders
         )
  }

  describe ".run(feed, output_formatter)" do
    before :each do
      @feed_runner = double('feed_runner')
      allow(described_class).to receive(:new).and_return(@feed_runner)
      allow(@feed_runner).to receive(:run)
      described_class.run(feed, output_formatter)
    end

    let(:feed_runner) {@feed_runner}

    it "initializes a FeedRunner with the given feed and output_formatter" do
      expect(described_class).to have_received(:new).with(feed,output_formatter)
    end

    it "calls #run on the feed_runner with an empty hash" do
      expect(feed_runner).to have_received(:run).with({})
    end
  end

  describe ".run(feed, output_formatter, run_opts)" do
    before :each do
      @feed_runner = double('feed_runner')
      allow(described_class).to receive(:new).and_return(@feed_runner)
      allow(@feed_runner).to receive(:run)
      described_class.run(feed, output_formatter, run_opts)
    end

    let(:feed_runner) {@feed_runner}
    let(:run_opts) { {foo: "bar"} }

    it "initializes a FeedRunner with the given feed and output_formatter" do
      expect(described_class).to have_received(:new).with(feed,output_formatter)
    end

    it "calls #run on the feed_runner with an empty hash" do
      expect(feed_runner).to have_received(:run).with(run_opts)
    end
  end

  context "an instance" do
    let(:feed_runner) { described_class.new(feed, output_formatter) }

    describe "#run" do
      context "fetching data" do
        before :each do
          allow(parser).to receive(:run).with(io)
        end

        context "when providing the :io argument" do
          it "should not call fetcher_builder, but initialize the parser with the thing we provided to :io"  do
            expect(fetcher_builder).not_to receive(:call)
            expect(fetcher).not_to receive(:fetch)
            feed_runner.run(:io => io)
          end
        end

        it "should generate a new fetcher via fetcher_builder.call, and then fetch" do
          expect(fetcher_builder).to receive(:call).and_call_original
          expect(fetcher).to receive(:fetch).and_return(io)
          feed_runner.run
        end
      end

      context "parsing" do
        before :each do
          allow(fetcher).to receive(:fetch).and_return(io)
        end

        it "should call the parser_block for each for each message data parsed" do
          record1 = Threatinator::Record.new('a1')
          record2 = Threatinator::Record.new('a2')
          record3 = Threatinator::Record.new('a3')
          expect(parser).to receive(:run).with(io).and_yield(record1).and_yield(record2).and_yield(record3)
          expect(feed.parser_block).to receive(:call).with(kind_of(Proc), record1).ordered
          expect(feed.parser_block).to receive(:call).with(kind_of(Proc), record2).ordered
          expect(feed.parser_block).to receive(:call).with(kind_of(Proc), record3).ordered
          feed_runner.run
        end
      end
      context "filtering" do
        before :each do
          allow(parser).to receive(:run).with(io)
          allow(fetcher).to receive(:fetch).and_return(io)
        end
        let(:filter) { double("filter") }
        let(:filter_builders) { [ lambda {filter} ] }
        it "should not call the parser_block if the data was filtered" do
          allow(filter).to receive(:filter?)
          allow(feed_runner).to receive(:_fetch).and_return(io)
          record1 = Threatinator::Record.new('a1')
          record2 = Threatinator::Record.new('a2')
          record3 = Threatinator::Record.new('a3')

          expect(parser).to receive(:run).with(io).and_yield(record1).and_yield(record2).and_yield(record3)
          expect(filter).to receive(:filter?).with(record1).ordered.and_return(false)
          expect(feed.parser_block).to receive(:call).with(kind_of(Proc), record1).ordered

          expect(filter).to receive(:filter?).with(record2).ordered.and_return(true)
          expect(filter).to receive(:filter?).with(record3).ordered.and_return(false)
          expect(feed.parser_block).to receive(:call).with(kind_of(Proc), record3).ordered

          feed_runner.run
        end
      end

      context "decoding" do
        before :each do
          allow(fetcher).to receive(:fetch).and_return(io)
        end
        let(:decoder1) { double("decoder") }
        let(:decoder2) { double("decoder") }
        let(:decoder3) { double("decoder") }
        let(:decoder_builders) { [ lambda {decoder1}, lambda {decoder2}, lambda {decoder3} ] }
        it "should run through each decoder in the order it was added to the feed" do
          decoded_io1 = double("decoded_io1")
          decoded_io2 = double("decoded_io2")
          decoded_io3 = double("decoded_io3")

          expect(decoder1).to receive(:decode).with(io).and_return(decoded_io1)
          expect(decoder2).to receive(:decode).with(decoded_io1).and_return(decoded_io2)
          expect(decoder3).to receive(:decode).with(decoded_io2).and_return(decoded_io3)
          expect(parser).to receive(:run).with(decoded_io3)
          feed_runner.run
        end

        it "should skip decoding if the :skip_decoding was set to true" do
          expect(parser).to receive(:run).with(io)
          feed_runner.run(skip_decoding: true)
        end
      end
    end
  end
end
