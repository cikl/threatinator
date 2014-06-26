require 'threatinator/instrumentation/record_report'

module Threatinator
  module Instrumentation
    class DetailedRecordReport < RecordReport
      attr_reader :record, :events
      def initialize(record)
        @record = record
        @events = []
        super(record)
      end

      def add_event(event)
        @events << event
        super(event)
      end
    end
  end
end
