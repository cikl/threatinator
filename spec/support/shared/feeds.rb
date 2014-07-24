require 'spec_helper'
require 'threatinator/feed_builder'
require 'threatinator/feed_runner'
require 'threatinator/outputs/null'
require 'threatinator/instrumentation/detailed_feed_report'
require 'pathname'

shared_context 'a parsed record' do
  # Expects :record_report and :record
  let(:status) { record_report.status }
  let(:events) { record_report.events }
end

shared_context 'a parsed feed' do 
  # expects :feed_report
  let(:record_reports) { feed_report.record_reports }
  let(:num_records_filtered) { feed_report.num_records_filtered }
  let(:num_records_parsed) { feed_report.num_records_parsed }
  let(:num_records_missed) { feed_report.num_records_missed }
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
  let(:output_formatter) { Threatinator::Outputs::Null.new(feed, $stdout) }
  let(:feed_runner) { Threatinator::FeedRunner.new(feed, output_formatter, :feed_report_class => Threatinator::Instrumentation::DetailedFeedReport) }
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
      before :each do
        sio = StringIO.new(data)
        @record = @record_report = nil
        cb = lambda do |record, rr|
          @record = record
          @record_report = rr
        end

        @feed_report = feed_runner.run(:io => sio, :record_callback => cb)
      end
      let(:feed_report) { @feed_report }
      it "should have handled exactly 1 record" do
        expect(feed_report.total).to eq(1)
      end

      describe "the record" do
        let(:record) { @record }
        let(:record_report) { @record_report }
        include_context 'a parsed record'
        instance_exec(&block)
      end
    end
  end

  def describe_parsing_the_file(filename, &block)
    filepath = Pathname.new(filename)
    relative_filename = filepath.relative_path_from(PROJECT_ROOT).to_s

    context("parsing the file '#{relative_filename}'", :caller => caller) do
      before :each do
        fio = File.open(filename, 'r')
        @feed_report = feed_runner.run(:io => fio)
        fio.close unless fio.closed?
      end
      let(:feed_report) { @feed_report }
      include_context "a parsed feed"
      instance_exec(&block)
    end
  end


end
