require 'csv'

module Threatinator
  module Actions
    module Run
      class CoverageObserver
        attr_reader :filename
        def initialize(filename)
          @filename = filename
          @csv = nil
        end

        def closed?
          return false if @csv.nil?
          @csv.closed?
        end

        def open
          @csv = ::CSV.open(@filename, "wb", :headers => [:status, :event_count, :line_number, :pos_start, :pos_end, :data], :write_headers => true)
        end

        # Handles FeedRunner observations
        def update(message, *args)
          case message
          when :record_missed
            log_record(:missed, args.shift, [])
          when :record_filtered
            log_record(:filtered, args.shift, [])
          when :record_parsed
            log_record(:parsed, args.shift, args.shift)
          when :end
            close
          when :start
            open
          end
        end

        # @param [Symbol] status :parsed, :missed, :filtered
        # @param [Threatinator::Record] record
        # @param [Array<Threatinator::Event>] events
        def log_record(status, record, events = [])
          return if closed?
          @csv.add_row(  [
            status, events.count, record.line_number, 
            record.pos_start, record.pos_end, record.data.inspect])
        end

        def close
          @csv.close unless closed?
        end
      end
    end
  end
end
