module Threatinator
  module Instrumentation
    class RecordReport
      attr_reader :event_count
      def initialize(record)
        @event_count = 0
        @filtered = false
      end

      def filtered?
        !!@filtered
      end

      def filtered!
        @filtered = true
      end

      def add_event(event)
        @event_count += 1
      end

      def parsed?
        not filtered? and @event_count > 0
      end

      def missed?
        not filtered? and @event_count == 0
      end

      def status
        return :filtered if filtered?
        return :missed if missed?
        return :parsed if parsed?
      end
    end
  end
end


