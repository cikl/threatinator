module Threatinator

  class OutputBuilder
    def output_class(_output_class)
      @output_class = _output_class
      self
    end

    def output_io(io)
      @output_io = io
      self
    end

    def build_for_feed(feed)
      @output_io ||= $stdout
      if @output_class.nil?
        raise ArgumentError.new("format_class not defined!")
      end
      @output_class.new(feed, @output_io)
    end
  end
end
