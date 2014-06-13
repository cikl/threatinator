module Threatinator
  # This a wrapper for the IO objects that we encounter. The intent is to 
  # provide a means for closing all IOs if they are chained together.
  class IOWrapper
    # @param [::IO, Threatinator::IOWrapper] io The IO to wrap.
    def initialize(io)
      @io = io
    end

    # @return the actual IO object that is wrapped (wherever that is).
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
    
    # @return [Boolean] true if closed, false if not closed
    def closed?
      @io.closed?
    end

    def self.wrap(io)
      self.new(io)
    end
  end
end
