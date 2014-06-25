module Threatinator
  class Record
    attr_reader :data, :line_number, :pos_start, :pos_end
    def initialize(data, opts = {})
      @data = data
      @line_number = opts[:line_number]
      @pos_start = opts[:pos_start]
      @pos_end = opts[:pos_end]
    end

    def ==(other)
      @data == other.data &&
        @line_number == other.line_number &&
        @pos_start == other.pos_start &&
        @pos_end == other.pos_end
    end

    def eql?(other)
      other.kind_of?(self.class) && self == other
    end
  end
end
