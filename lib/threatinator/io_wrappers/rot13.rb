require 'threatinator/io_wrappers/simple'

module Threatinator
  module IOWrappers
    # This is just an example wrapper that will rot-13 the data as it is being
    # read.
    class Rot13 < Threatinator::IOWrappers::Simple
      def _native_read(read_length)
        if ret = super(read_length)
          ret.tr! 'A-Za-z','N-ZA-Mn-za-m'
        end
        ret
      end
    end
  end
end


