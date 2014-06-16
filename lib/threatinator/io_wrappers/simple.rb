require 'threatinator/io_wrapper'

module Threatinator
  module IOWrappers
    # This a wrapper for the IO objects that we encounter. The intent is to 
    # provide a means for closing all IOs if they are chained together.
    class Simple < Threatinator::IOWrapper
      attr_reader :io

      def initialize(io, opts = {})
        @io = io
        super(opts)
      end
    end
  end
end
