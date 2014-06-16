require 'threatinator/io_wrapper'

module Threatinator
  # Chains together a series of IOWrappers to an IO. This allows us to 
  # easily configure a series of mutations decode/tweak the data.
  class IOChain < IOWrapper
    def initialize(io)
      @chain = [ io ]
    end

    # Always returns the last io in the chain.
    def io
      @chain.last
    end

    # @return [Integer] the number of IOs in the chain.
    def num_io_wrappers
      self.each_io_wrapper.count
    end

    def each_io_wrapper
      return enum_for(:each_io_wrapper) unless block_given?
      @chain.each do |io|
        yield(io)
      end
    end

    # Specifies that 
    def push_io_wrapper(io_wrapper_klass, opts = {})
      @chain << io_wrapper_klass.new(@chain.last, opts)
      nil
    end
  end
end

