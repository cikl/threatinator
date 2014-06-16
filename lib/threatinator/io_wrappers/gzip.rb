require 'zlib'
require 'threatinator/io_wrapper'
require 'threatinator/exceptions'

module Threatinator
  module IOWrappers
    # Wraps 
    class Gzip < Threatinator::IOWrapper

      def initialize(upstream_io, opts = {})
        gzip_io = Zlib::GzipReader.new(upstream_io)
        super(gzip_io, opts)
      end

      def _handle_error(e)
        case e
        when Zlib::GzipFile::Error, ::IOError
          return Threatinator::Exceptions::IOWrapperError.new
        else 
          e
        end
      end

    end
  end
end
