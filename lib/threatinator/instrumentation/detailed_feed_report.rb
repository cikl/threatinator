require 'threatinator/instrumentation/feed_report'
module Threatinator
  module Instrumentation
    class DetailedFeedReport < FeedReport
      def initialize(feed)
        super(feed)
        @record_reports = []
      end

      def add_record_report(record_report)
        super(record_report)
        @record_reports << record_report
      end

      def num_records_parsed
        self.records_parsed.count
      end

      def records_parsed
        @records_parsed ||= @record_reports.select { |r| r.parsed? }
      end

      def num_records_missed
        self.records_missed.count
      end

      def records_missed
        @records_missed ||= @record_reports.select { |r| r.missed? }
      end

      def num_records_filtered
        self.records_filtered.count
      end

      def records_filtered
        @records_filtered ||= @record_reports.select { |r| r.filtered? }
      end
    end
  end
end


