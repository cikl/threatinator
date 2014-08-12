require 'threatinator/event'

module Threatinator
  class EventBuilder
    attr_reader :total
    def initialize(feed)
      @feed = feed
      @built_events = []
      @total = 0
    end

    def each_built_event
      @built_events.each do |event|
        yield event
      end
      @built_events.clear
    end

    def count
      @built_events.count
    end

    def clear
      @built_events.clear
    end

    def create_event_proc
      self.method(:create_event).to_proc
    end

    def create_event
      event = Threatinator::Event.new
      event.feed_provider = @feed.provider
      event.feed_name = @feed.name
      yield(event)
      @total += 1
      @built_events << event
    end
  end
end

