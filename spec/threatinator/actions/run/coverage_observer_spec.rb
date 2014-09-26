require 'spec_helper'
require 'threatinator/actions/run/coverage_observer'

describe Threatinator::Actions::Run::CoverageObserver do
  before :each do
    @tmpdir = Dir.mktmpdir
  end

  after :each do
    observer.update(:end)
    FileUtils.remove_entry_secure @tmpdir
  end

  let(:filename) { File.join(@tmpdir, "coverage.csv") }
  let(:observer) { described_class.new(filename) }

  it_should_behave_like "a FeedRunner observer"

  context "#update(:start)" do
    it "creates the file specified by filename" do
      expect(File.exist?(filename)).to eq(false)
      observer.update(:start)
      expect(File.exist?(filename)).to eq(true)
    end
  end

  context "#update(:end)" do
    before :each do
      observer.update(:start)
    end

    context "when at least one record has been written" do
      before :each do
        observer.update(:record_parsed, build(:record), [ build(:event) ])
        observer.update(:end)
      end

      specify "the first line is the header" do
        data = File.read(filename)
        expect(data.lines.to_a.first).to eq("status,event_count,line_number,pos_start,pos_end,data,message\n")
      end

      it "closes the file so that no more records will be written" do
        data_before = File.read(filename)
        10.times do
          observer.update(:record_missed, build(:record))
        end
        data_after = File.read(filename)
        expect(data_before).to eq(data_after)
      end
    end
  end

  context "#update(:record_filtered, record)" do
    before :each do
      observer.update(:start)
    end

    it "writes a csv entry to the file indicating that it was filtered" do
      record = build(:record, line_number: 23, pos_start: 99, pos_end: 105, data: "foobar\r\n")
      observer.update(:record_filtered, record)
      observer.update(:end)
      csv = CSV.read(filename, headers: true, header_converters: :symbol)
      expect(csv[-1].to_hash).to eq(
        status: "filtered",
        event_count: "0",
        line_number: "23",
        pos_start: "99",
        pos_end: "105",
        data: '"foobar\r\n"',
        message: ''
      )
    end
  end

  context "#update(:record_filtered, record)" do
    before :each do
      observer.update(:start)
    end

    it "writes a csv entry to the file indicating that it was missed" do
      record = build(:record, line_number: 22, pos_start: 98, pos_end: 104, data: "blabla\r\n")
      observer.update(:record_filtered, record)
      observer.update(:end)
      csv = CSV.read(filename, headers: true, header_converters: :symbol)
      expect(csv[-1].to_hash).to eq(
        status: "filtered",
        event_count: "0",
        line_number: "22",
        pos_start: "98",
        pos_end: "104",
        data: '"blabla\r\n"',
        message: ''
      )
    end
  end

  context "#update(:record_parsed, record, events)" do
    before :each do
      observer.update(:start)
    end

    let(:record) { build(:record, line_number: 1, pos_start: 0, pos_end: 10, data: "woofwoof\r\n") }
    let(:events) { [ build(:event), build(:event) ] }

    it "writes a csv entry to the file indicating that it was parsed, with the number of events" do
      observer.update(:record_parsed, record, events)
      observer.update(:end)
      csv = CSV.read(filename, headers: true, header_converters: :symbol)
      expect(csv[-1].to_hash).to eq(
        status: "parsed",
        event_count: "2",
        line_number: "1",
        pos_start: "0",
        pos_end: "10",
        data: '"woofwoof\r\n"',
        message: ''
      )
    end
  end

  context "#update(:record_error, record, errors)" do
    before :each do
      observer.update(:start)
    end

    let(:record) { build(:record, line_number: 1, pos_start: 0, pos_end: 10, data: "woofwoof\r\n") }
    let(:errors) { 
      [
        Threatinator::Exceptions::EventBuildError.new("error 1"),
        Threatinator::Exceptions::EventBuildError.new("error 2"),
        Threatinator::Exceptions::EventBuildError.new("error 3")
      ]
    }

    it "writes a csv entry to the file indicating it encountered an error, with the error messages" do
      observer.update(:record_error, record, errors)
      observer.update(:end)
      csv = CSV.read(filename, headers: true, header_converters: :symbol)
      expect(csv[-1].to_hash).to eq(
        status: "error",
        event_count: "0",
        line_number: "1",
        pos_start: "0",
        pos_end: "10",
        data: '"woofwoof\r\n"',
        message: 'error 1, error 2, error 3'
      )
    end
  end
end
