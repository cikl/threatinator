module Threatinator
  class Output
    attr_reader :output_io, :feed
    protected :output_io, :feed

    def initialize(feed, output_io)
      @feed = feed
      @output_io = output_io
    end

    def close
      @output_io.close
    end

    def handle_event(event)
      raise NotImplementedError.new("#{self.class}#handle_event is not implemented")
    end
  end
end
