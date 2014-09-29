require 'spec_helper'
require 'threatinator/feed_runner'

describe Threatinator::FeedRunner do
  class DummyParser < Threatinator::Parser
    def initialize(records, opts = {})
      @records = records
    end

    def run(io)
      @records.each do |record|
        yield(record)
      end
    end
  end

  class DummyFetcher < Threatinator::Fetcher
    def initialize(io, opts = {})
      @io = io
    end

    def fetch
      return @io
    end
  end

  class DummyDecoder < Threatinator::Decoder
    def initialize(io)
      @io = io
    end

    def decode(arg_io)
      return @io
    end
  end

  class TestObserver
    attr_reader :updates
    def initialize
      @updates = []
    end

    def update(*args)
      @updates << args
    end
  end

  class DummyOutput < Threatinator::Output
    def handle_event(event); end
    def finish; end
  end

  let(:output_formatter ) { DummyOutput.new(nil) }
  let(:io) { double("io") }
  let(:fetcher) { DummyFetcher.new(io) }

  let(:record1) { Threatinator::Record.new('a1') }
  let(:record2) { Threatinator::Record.new('a2') }
  let(:record3) { Threatinator::Record.new('a3') }
  let(:records) { [ record1, record2, record3 ] }
  let(:parser) { DummyParser.new(records) }
  let(:parser_block) { lambda { |*args| } }

  let(:filters) { [] }
  let(:decoders) { [] }

  let(:feed) {
    build(:feed, fetcher: fetcher, 
          parser: parser, filters: filters,
          decoders: decoders, parser_block: parser_block
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
    let(:observer) { TestObserver.new }

    before :each do
      feed_runner.add_observer(observer)
      allow(observer).to receive(:update).and_call_original
    end

    describe "#run" do
      it "notifies the observer with :start before anything else" do
        expect(observer.updates.first).to be_nil
        feed_runner.run()
        expect(observer.updates.first).to eq([:start])
      end

      it "fetches, decodes, and then parses records" do
        expect(observer).to receive(:update).with(:start).ordered
        expect(observer).to receive(:update).with(:start_fetch).ordered
        expect(observer).to receive(:update).with(:end_fetch).ordered
        expect(observer).to receive(:update).with(:start_decode).ordered
        expect(observer).to receive(:update).with(:end_decode).ordered
        expect(observer).to receive(:update).with(:start_parse_record, record1).ordered
        expect(observer).to receive(:update).with(:end_parse_record, record1).ordered
        expect(observer).to receive(:update).with(:start_parse_record, record2).ordered
        expect(observer).to receive(:update).with(:end_parse_record, record2).ordered
        expect(observer).to receive(:update).with(:start_parse_record, record3).ordered
        expect(observer).to receive(:update).with(:end_parse_record, record3).ordered
        expect(observer).to receive(:update).with(:end).ordered
        feed_runner.run()
      end

      it "notifies the observer with :end last" do
        feed_runner.run()
        expect(observer.updates.last).to eq([:end])
      end

      context "with :io => io" do
        it "does not build or run the fetcher" do
          expect(feed.fetcher_builder).not_to receive(:call)
          feed_runner.run(:io => io)
        end

        it "does not notify the observer with :start_fetch or :end_fetch" do
          expect(observer).not_to receive(:update).with(:start_fetch)
          expect(observer).not_to receive(:update).with(:end_fetch)
          feed_runner.run(:io => io)
        end
      end

      context "without :io" do
        it "should generate a new fetcher via fetcher_builder.call, and then fetch" do
          expect(feed.fetcher_builder).to receive(:call).and_call_original
          expect(fetcher).to receive(:fetch).and_call_original
          feed_runner.run
        end

        it "notifies the observer with :start_fetch, then fetches, then notifies observer with :end_fetch" do
          expect(observer).to receive(:update).with(:start_fetch).ordered
          expect(fetcher).to receive(:fetch).and_call_original.ordered
          expect(observer).to receive(:update).with(:end_fetch).ordered
          feed_runner.run()
        end
      end

      it "calls the feed.parser_block for each for each message data parsed" do
        expect(feed.parser_block).to receive(:call).with(kind_of(Proc), record1).ordered
        expect(feed.parser_block).to receive(:call).with(kind_of(Proc), record2).ordered
        expect(feed.parser_block).to receive(:call).with(kind_of(Proc), record3).ordered
        feed_runner.run()
      end


      context "when handling record" do
        let(:records) { [ record1 ] }

        it "notifies observer with :start_parse_record, and the record prior to handling" do
          expect(observer).to receive(:update).with(:start_parse_record, record1).ordered
          expect(feed.parser_block).to receive(:call).with(kind_of(Proc), record1).ordered
          feed_runner.run()
        end

        it "notifies observer with :end_parse_record, and the record after handling" do
          expect(feed.parser_block).to receive(:call).with(kind_of(Proc), record1).ordered
          expect(observer).to receive(:update).with(:end_parse_record, record1).ordered
          feed_runner.run()
        end

        context "when the record is parsed into one or more events" do
          let(:parser_block) { 
            lambda do |cep, record| 
              cep.call do |eb|
                eb.type = :c2
                eb.add_ipv4('1.1.1.1')
              end
              cep.call do |eb|
                eb.type = :c2
                eb.add_ipv4('2.2.2.2')
              end
            end
          }

          it "notifies the observer with (:record_parsed, record, events) for each event" do
            expect(observer).to receive(:update).with(
              :record_parsed, record1, satisfy { |events| 
                expect(events[0].ipv4s).to contain_exactly(build(:ipv4, ipv4: '1.1.1.1'))
                expect(events[1].ipv4s).to contain_exactly(build(:ipv4, ipv4: '2.2.2.2'))
              }) 

            feed_runner.run()
          end
        end

        context "when no events have been parsed from the record" do
          let(:parser_block) { 
            lambda do |cep, record| 
            end
          }

          it "notifies the observer with (:record_missed, record) for each event" do
            expect(observer).to receive(:update).with(:record_missed, record1)
            feed_runner.run()
          end
        end

        context "when a record has been filtered" do
          let(:filters) { [ lambda { |record| true } ] }
          it "notifies the observer with (:record_filtered, record)" do
            expect(observer).to receive(:update).with(:record_filtered, record1)
            feed_runner.run()
          end
        end

        context "when a record has an event that fails to build" do
          let(:parser_block) { 
            lambda do |cep, record| 
              cep.call do |eb|
                eb.type = :c2
              end
              cep.call do |eb|
                eb.type = :asdf
              end
            end
          }

          it "notifies the observer with (:record_error, record, array_of_errors)" do
            expect(observer).to receive(:update).with(:record_error, record1, a_collection_containing_exactly(
              kind_of(Threatinator::Exceptions::EventBuildError)
            ))
            feed_runner.run()
          end

          it "does not notify the observer of any events that may have NOT have errors" do
            expect(observer).not_to receive(:update).with(:record_parsed, record1, kind_of(Object))
            feed_runner.run()
          end
        end

      end

      context "filtering" do
        let(:filters) { [ lambda { |record| record.data == "a2" } ] }

        before :each do
          allow(fetcher).to receive(:fetch).and_return(io)
        end

        it "only calls the parser_block for data that was not filtered" do
          expect(feed.parser_block).to receive(:call).with(kind_of(Proc), record1).ordered
          expect(feed.parser_block).to receive(:call).with(kind_of(Proc), record3).ordered
          feed_runner.run()
        end
      end

      context "decoding" do
        let(:decoded_io1) { double('decoded_io1') }
        let(:decoded_io2) { double('decoded_io2') }
        let(:decoded_io3) { double('decoded_io3') }
        let(:decoder1) { DummyDecoder.new(decoded_io1) }
        let(:decoder2) { DummyDecoder.new(decoded_io2) }
        let(:decoder3) { DummyDecoder.new(decoded_io3) }
        let(:decoders) { [ decoder1, decoder2, decoder3 ] }

        context "without :skip_decoding" do
          it "notifies the observer with :start_decode, decodes, and then notifies the observer with :end_decode" do
            expect(observer).to receive(:update).with(:start_decode).ordered
            expect(decoder1).to receive(:decode).with(io).and_call_original.ordered
            expect(decoder2).to receive(:decode).with(decoded_io1).and_call_original.ordered
            expect(decoder3).to receive(:decode).with(decoded_io2).and_call_original.ordered
            expect(observer).to receive(:update).with(:end_decode).ordered
            feed_runner.run
          end

          it "should run through each decoder in the order it was added to the feed" do
            expect(decoder1).to receive(:decode).with(io).and_call_original
            expect(decoder2).to receive(:decode).with(decoded_io1).and_call_original
            expect(decoder3).to receive(:decode).with(decoded_io2).and_call_original
            expect(parser).to receive(:run).with(decoded_io3)
            feed_runner.run
          end
        end

        context "with :skip_decoding => true" do
          it "does not decode" do
            expect(observer).not_to receive(:update).with(:start_decode)
            expect(observer).not_to receive(:update).with(:end_decode)
            expect(parser).to receive(:run).with(io)
            feed_runner.run(skip_decoding: true)
          end
        end
      end
    end
  end
end
