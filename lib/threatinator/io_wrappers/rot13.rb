require 'threatinator/io_wrapper_mixin'
require 'threatinator/io_wrappers/simple'

module Threatinator
  module IOWrappers
    # This is just an example wrapper that will rot-13 the data as it is being
    # read.
    class Rot13 < Threatinator::IOWrappers::Simple
      def _native_read(*args)
        ret = to_io.read(*args)
        ret.tr 'A-Za-z','N-ZA-Mn-za-m'
      end
    end
  end
end


