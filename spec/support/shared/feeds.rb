require 'spec_helper'
require 'threatinator/feed_builder'
require 'threatinator/feed_runner'
require 'threatinator/plugins/output/null'
require 'pathname'

shared_context 'a parsed record' do
  # Expects :observer
  before :each do
    @record, @status, @events = observer.first
  end
  let(:record) { @record }
  let(:events) { @events }
  let(:status) { @status }
end

shared_context 'a parsed feed' do 
  # expects :observer
  let(:events) { observer.events }
  let(:records) { observer.records }
  let(:num_records) { observer.count }
  let(:num_records_filtered) { observer.num_records_filtered }
  let(:num_records_parsed) { observer.num_records_parsed }
  let(:num_records_missed) { observer.num_records_missed }
  let(:num_records_errored) { observer.num_records_errored }

  it "should have 0 error records" do
    expect(num_records_errored).to eq(0)
  end

  it "should have missed 0 records" do
    expect(num_records_missed).to eq(0)
  end
end

shared_context 'for feeds', :feed => lambda { true } do
  _feed_path = Pathname.new(self.description)
  if _feed_path.relative?
    # It's relative to the root of our project.
   _feed_path = PROJECT_ROOT + _feed_path 
  end
  _feed_path = _feed_path.expand_path

  before :all do
    @feed_builder = Threatinator::FeedBuilder.from_file(_feed_path.to_s)
  end

  let(:feed_path) { feed_path.to_s }
  let(:output_formatter) { Threatinator::Plugins::Output::Null.new(Threatinator::Plugins::Output::Null::Config.new) }
  let(:feed_runner) { Threatinator::FeedRunner.new(feed, output_formatter) }
  let(:feed) { @feed_builder.build() }
end

shared_examples_for 'any feed', :feed do
  # Expects :provider, :name, :feed
  subject { feed } 
  it { should be_a(Threatinator::Feed) }

  describe "#provider" do
    subject { feed.provider }
    it { is_expected.to be_a(::String) }
    it { is_expected.to eq(provider) }
  end

  describe "#name" do
    subject { feed.name}
    it { is_expected.to be_a(::String) }
    it { is_expected.to eq(name) }
  end

  describe "#parser_block" do
    subject { feed.parser_block }
    it { is_expected.to be_a(::Proc) }
  end

  describe "#fetcher_builder" do
    subject { feed.fetcher_builder }
    it { is_expected.to be_a ::Proc }
    specify "when called, it should generate a kind of Threatinator::Fetcher" do
      expect(subject.call).to be_kind_of(Threatinator::Fetcher)
    end
  end

  describe "#parser_builder" do
    subject { feed.parser_builder }
    it { is_expected.to be_a ::Proc }

    specify "when called, it should generate a kind of Threatinator::Parser" do
      expect(subject.call).to be_kind_of(Threatinator::Parser)
    end
  end

  describe "#filter_builders" do
    subject { feed.filter_builders }

    it "should be an Array of Proc objects" do
      expect(subject).to be_an ::Array
    end

    specify "each Proc, when called, should generate an object that responds to :filter?" do
      subject.each do |filter_builder|
        expect(filter_builder.call).to respond_to(:filter?)
      end
    end
  end

  describe "#decoder_builders" do
    subject { feed.decoder_builders }

    it "should be an Array of Proc objects" do
      expect(subject).to be_an ::Array
    end

    specify "each Proc, when called, should generate a kind of Threatinator::Decoder" do
      subject.each do |decoder_builder|
        expect(decoder_builder.call).to be_kind_of(Threatinator::Decoder)
      end
    end
  end
end

module FeedHelpers
  class FeedRunnerObserver
    include Enumerable
    attr_reader :records, :statuses, :events, :num_records_filtered, 
      :num_records_missed, :num_records_parsed, :num_records_errored

    def initialize
      @records = []
      @statuses = []
      @events = []
      @num_records_filtered = 0
      @num_records_parsed = 0
      @num_records_missed = 0
      @num_records_errored = 0
    end

    def each
      @records.each_with_index do |record, i|
        yield(record, @statuses[i], @events[i])
      end
    end

    # Handles FeedRunner observations
    def update(message, *args)
      case message
      when :record_missed
        @records << args.shift
        @statuses << :missed
        @events << []
        @num_records_missed += 1
      when :record_filtered
        @records << args.shift
        @statuses << :filtered
        @events << []
        @num_records_filtered += 1
      when :record_parsed
        @records << args.shift
        @statuses << :parsed
        @events << args.shift
        @num_records_parsed += 1
      when :record_error
        @records << args.shift
        @statuses << :error
        @events << []
        @num_records_errored += 1
      end
    end
  end

  module FeedHelperMethods
    def it_fetches_url(url)
      describe 'fetching' do
        it "should fetch the url #{url}" do
          stub_request(:get, url)
          feed.fetcher_builder.call().fetch()
          expect(a_request(:get, url)).to have_been_made
        end
      end
    end

    def feed_data(filename)
      (FEED_DATA_ROOT + filename).to_s
    end

    def describe_parsing_a_record(data, &block)
      context("parsing a record from '#{data}'", :caller => caller) do
        let(:observer) { FeedRunnerObserver.new }
        before :each do
          sio = StringIO.new(data)
          feed_runner.add_observer(observer)
          feed_runner.run(:io => sio, :skip_decoding => true)
          @status, @record, @events = observer.first
        end

        after :each do
          feed_runner.delete_observer(observer)
        end

        it "should have handled exactly 1 record" do
          expect(observer.count).to eq(1)
        end

        describe "the record" do
          include_context 'a parsed record'
          instance_exec(&block)
        end
      end
    end

    def describe_parsing_the_file(filename, &block)
      filepath = Pathname.new(filename)
      relative_filename = filepath.relative_path_from(PROJECT_ROOT).to_s

      context("parsing the file '#{relative_filename}'", :caller => caller) do
        let(:observer) { FeedRunnerObserver.new }
        before :each do
          fio = File.open(filename, 'r')
          feed_runner.add_observer(observer)
          feed_runner.run(:io => fio)
          fio.close unless fio.closed?
        end

        after :each do
          feed_runner.delete_observer(observer)
        end

        include_context "a parsed feed"
        instance_exec(&block)
      end
    end
  end
end
