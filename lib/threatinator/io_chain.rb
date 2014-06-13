module Threatinator
  # Chains together a series of IOWrappers to an IO. This allows us to 
  # easily configure a series of mutations decode/tweak the data.
  class IOChain
    def initialize(first_io)
      @first_io = first_io
      @chain = [ first_io ]
    end

    # @return [Integer] the number of IOs in the chain.
    def count
      self.each.count
    end
    alias_method :size, :count
    alias_method :length, :count

    def each
      return enum_for(:each) unless block_given?
      @chain.each do |io|
        yield(io)
      end
    end

    # Specifies that 
    def push(io_wrapper_klass, opts = {})
      @chain << io_wrapper_klass.new(@chain.last, opts)
      nil
    end

    # Reads from the IO. 
    # @see ::IO
    def read(*args)
      @chain.last.read(*args)
    end

    # Closes the io
    def close()
      @chain.reverse.each do |io|
        io.close unless io.closed?
      end
    end
    
    # @return [Boolean] true if closed, false if not closed
    def closed?
      @chain.last.closed?
    end
  end
end

