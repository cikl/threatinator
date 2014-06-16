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

      def _native_read(read_length)
        ret = super(read_length)

        # If we've hit the end of the file, retrieve any 'unused' data. This
        # only acts as a way to ensure the footer is read, so that we can 
        # validate the file has decompressed properly.
        io.unused if eof?

        ret
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
