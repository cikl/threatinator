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

      def _handle_error
        begin
          yield
        rescue Zlib::GzipFile::Error => e
          raise Threatinator::Exceptions::IOWrapperError.new
        end
      end

    end
  end
end
