module Threatinator
  module Actions
    module Run
      class StatusObserver
        attr_reader :missed, :filtered, :parsed, :errors
        def initialize
          @missed = @filtered = @parsed = @errors = 0
        end

        def total
          @missed + @filtered + @parsed + @errors
        end

        # Handles FeedRunner observations
        def update(message, *args)
          case message
          when :record_missed
            @missed += 1
          when :record_filtered
            @filtered += 1
          when :record_parsed
            @parsed += 1
          when :record_error
            @errors += 1
          end
        end

        def missed?; @missed > 0; end
        def parsed?; @parsed > 0; end
        def filtered?; @filtered > 0; end
        def errors?; @errors > 0; end

      end
    end
  end
end

