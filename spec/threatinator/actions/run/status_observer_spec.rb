require 'spec_helper'
require 'threatinator/actions/run/status_observer'

describe Threatinator::Actions::Run::StatusObserver do
  let(:observer) { described_class.new() }
  let(:record) { build(:record, line_number: 23, pos_start: 99, pos_end: 105, data: "foobar\r\n") }

  describe "#filtered" do
    it "returns the number of records that have been filtered" do
      expect(observer.filtered).to eq(0)
      observer.update(:record_filtered, record)
      expect(observer.filtered).to eq(1)
    end
  end

  describe "#filtered?" do
    it "returns true if any records were filtered, false otherwise" do
      expect(observer.filtered?).to eq(false)
      observer.update(:record_filtered, record)
      expect(observer.filtered?).to eq(true)
    end
  end

  describe "#missed" do
    it "returns the number of records that have been missed" do
      expect(observer.missed).to eq(0)
      observer.update(:record_missed, record)
      expect(observer.missed).to eq(1)
    end
  end

  describe "#missed?" do
    it "returns true if any records were missed, false otherwise" do
      expect(observer.missed?).to eq(false)
      observer.update(:record_missed, record)
      expect(observer.missed?).to eq(true)
    end
  end

  describe "#parsed" do
    it "returns the number of records that have been parsed" do
      expect(observer.parsed).to eq(0)
      observer.update(:record_parsed, record)
      expect(observer.parsed).to eq(1)
    end
  end

  describe "#parsed?" do
    it "returns true if any records were parsed, false otherwise" do
      expect(observer.parsed?).to eq(false)
      observer.update(:record_parsed, record)
      expect(observer.parsed?).to eq(true)
    end
  end

  describe "#total" do
    it "returns the total number of records that were parsed, missed, and filtered" do
      expect(observer.total).to eq(0)
      10.times { observer.update(:record_parsed, record) }
      10.times { observer.update(:record_missed, record) }
      10.times { observer.update(:record_filtered, record) }
      expect(observer.total).to eq(30)
    end
  end
end

