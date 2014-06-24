require 'threatinator/event'

module Threatinator
  class EventBuilder
    def initialize(output = nil)
      @output = output
    end

    def create_event
      event = Threatinator::Event.new
      yield(event)
    end
  end
end

