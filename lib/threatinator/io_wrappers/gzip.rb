require 'zlib'
require 'threatinator/io_wrapper_mixin'
require 'threatinator/exceptions'

module Threatinator
  module IOWrappers
    # Wraps 
    class Gzip
      include Threatinator::IOWrapperMixin

      def initialize(upstream_io, opts = {})
        @io = Zlib::GzipReader.new(upstream_io)
      end

      def to_io
        @io
      end

      def _handle_error(e)
        case e
        when Zlib::GzipFile::Error
          return Threatinator::Exceptions::IOWrapperError.new
        else 
          e
        end
      end

    end
  end
end
