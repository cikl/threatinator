require 'threatinator/io_wrapper_mixin'

module Threatinator
  module IOWrappers
    # This a wrapper for the IO objects that we encounter. The intent is to 
    # provide a means for closing all IOs if they are chained together.
    class Simple
      include Threatinator::IOWrapperMixin

      # @param [IO] io An IO-like object to wrap. 
      # @param [Hash] opts A hash of options.
      def initialize(io, opts = {})
        @io = io
      end

      # @return the actual IO object that is wrapped (wherever that is).
      def to_io
        @io.to_io
      end

    end
  end
end
