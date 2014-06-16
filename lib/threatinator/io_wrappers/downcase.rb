require 'threatinator/io_wrappers/simple'

module Threatinator
  module IOWrappers
    # This is just an example wrapper that will downcase any text as it is 
    # being read.
    class Downcase < Threatinator::IOWrappers::Simple
      def _native_read(read_length)
        if ret = super(read_length)
          ret.downcase!
        end
        ret
      end
    end
  end
end

