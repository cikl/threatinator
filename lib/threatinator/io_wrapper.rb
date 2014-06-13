module Threatinator
  # This a wrapper for the IO objects that we encounter. The intent is to 
  # provide a means for closing all IOs if they are chained together.
  class IOWrapper
    def initialize(io)
      @io = io
    end

    # @return the underlying IO object.
    def to_io
      @io.to_io
    end

    # Reads from the IO. 
    # @see ::IO
    def read(*args)
      @io.read(*args)
    end

    # Closes the io
    def close()
      @io.close
    end

    def self.wrap(io)
      self.new(io)
    end
  end
end
