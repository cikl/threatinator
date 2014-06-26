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
  its(:provider) { is_expected.to eq(provider) }
  its(:name) { is_expected.to eq(name) }
  it { should be_a(Threatinator::Feed) }
end

module FeedHelpers
  def it_fetches_url(url)
    describe 'fetching' do
      it "should fetch the url #{url}" do
        stub_request(:get, url)
        feed_runner._fetch()
        expect(a_request(:get, url)).to have_been_made
      end
    end
  end

  def feed_data(filename)
    (FEED_DATA_ROOT + filename).to_s
  end

  def describe_parsing_a_record(data, &block)
    context("parsing a record from '#{data}'", :caller => caller) do
      let(:record) { Threatinator::Record.new(data) }
      let(:record_report) { feed_runner.parse_record(record) }
      include_context 'a parsed record'
      instance_exec(&block)
    end
  end

  def describe_parsing_the_file(filename, &block)
    filepath = Pathname.new(filename)
    relative_filename = filepath.relative_path_from(PROJECT_ROOT).to_s

    context("parsing the file '#{relative_filename}'", :caller => caller) do
      before :each do
        fio = File.open(filename, 'r')
        @feed_report = feed_runner.run(:io => fio)
        fio.close
      end
      let(:feed_report) { @feed_report }
      include_context "a parsed feed"
      instance_exec(&block)
    end
  end


end
