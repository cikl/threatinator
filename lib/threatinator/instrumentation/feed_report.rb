require 'threatinator/instrumentation/record_report'
module Threatinator
  module Instrumentation
    class FeedReport
      attr_reader :num_records_parsed, :num_records_filtered, 
        :num_records_missed

      def initialize()
        @num_records_parsed = 0
        @num_records_missed = 0
        @num_records_filtered = 0
      end

      def wrap_record(record)
        RecordReport.new(record)
      end

      def monitor(record)
        rr = wrap_record(record)
        yield(rr)
        return rr
      ensure
        add_record_report(rr)
      end

      def add_record_report(record_report)
        if record_report.parsed?
          @num_records_parsed += 1
        elsif record_report.filtered?
          @num_records_filtered += 1
        elsif record_report.missed?
          @num_records_missed += 1
        end
      end
    end
  end
end

