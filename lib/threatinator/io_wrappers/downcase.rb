require 'threatinator/io_wrapper_mixin'
require 'threatinator/io_wrappers/simple'

module Threatinator
  module IOWrappers
    # This is just an example wrapper that will downcase any text as it is 
    # being read.
    class Downcase < Threatinator::IOWrappers::Simple
      def _native_read(*args)
        ret = to_io.read(*args)
        ret.downcase!
      end
    end
  end
end

