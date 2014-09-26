require 'spec_helper'
require 'threatinator/feed_runner'

shared_examples_for "a FeedRunner observer" do
  describe "#update(:start)" do
    after :each do
      observer.update(:end)
    end
    it "does not raise any errors when handling a :start event" do
      expect {
        observer.update(:start)
      }.not_to raise_error
    end
  end

  describe "#update(:end)" do
    before :each do
      observer.update(:start)
    end

    it "does not raise any errors when handling an :end event" do
      expect {
        observer.update(:end)
      }.not_to raise_error
    end
  end

  context "once started" do
    before :each do
      observer.update(:start)
    end

    after :each do
      observer.update(:end)
    end

    let(:record) { build(:record, line_number: 23, pos_start: 99, pos_end: 105, data: "foobar\r\n") }

    describe "#update(:start_fetch)" do
      it "does not raise any errors when handling an :start_fetch event" do
        expect {
          observer.update(:start_fetch)
        }.not_to raise_error
      end
    end

    describe "#update(:end_fetch)" do
      it "does not raise any errors when handling an :end_fetch event" do
        expect {
          observer.update(:end_fetch)
        }.not_to raise_error
      end
    end

    describe "#update(:start_decode)" do
      it "does not raise any errors when handling an :start_decode event" do
        expect {
          observer.update(:start_decode)
        }.not_to raise_error
      end
    end

    describe "#update(:end_decode)" do
      it "does not raise any errors when handling an :end_decode event" do
        expect {
          observer.update(:end_decode)
        }.not_to raise_error
      end
    end

    describe "#update(:start_parse_record, record)" do
      it "does not raise any errors when handling an :start_parse_record event" do
        expect {
          observer.update(:start_parse_record, record)
        }.not_to raise_error
      end
    end

    describe "#update(:end_parse_record, record)" do
      it "does not raise any errors when handling an :end_parse_record event" do
        expect {
          observer.update(:end_parse_record, record)
        }.not_to raise_error
      end
    end

    describe "#update(:record_filtered, record)" do
      it "does not raise any errors when handling a :record_filtered event" do
        expect {
          observer.update(:record_filtered, record)
        }.not_to raise_error
      end
    end

    describe "#update(:record_missed, record)" do
      it "does not raise any errors when handling a :record_missed event" do
        expect {
          observer.update(:record_missed, record)
        }.not_to raise_error
      end
    end

    describe "#update(:record_parsed, record, events)" do
      it "does not raise any errors when handling a :record_parsed event" do
        expect {
          observer.update(:record_missed, record, [build(:event)])
        }.not_to raise_error
      end
    end

    describe "#update(:record_error, record, array_of_errors)" do
      it "does not raise any errors when handling a :record_error event" do
        errors = [
          Threatinator::Exceptions::EventBuildError.new("error 1"),
          Threatinator::Exceptions::EventBuildError.new("error 2"),
          Threatinator::Exceptions::EventBuildError.new("error 3")
        ]
        expect {
          observer.update(:record_missed, record, errors)
        }.not_to raise_error
      end
    end

    it "does not raise any errors when handling unknown messages" do
      expect {
        observer.update(:flibby_floo, record)
      }.not_to raise_error
    end

    it "does not raise any errors when handling extra arguments" do
      expect {
        observer.update(:flibby_floo, record, 1, 2, 3, 4)
      }.not_to raise_error
    end
  end
end
