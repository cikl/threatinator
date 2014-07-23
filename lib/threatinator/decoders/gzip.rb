require 'threatinator/decoder'
require 'threatinator/exceptions'
require 'zlib'
require 'tempfile'
require 'pp'

module Threatinator
  module Decoders
    class Gzip < Threatinator::Decoder
      # Decompresses the io using Gzip.
      # @param (see Threatinator::Decoder#decode)
      def decode(io)
        zio = Zlib::GzipReader.new(io, encoding: "binary")
        tempfile = Tempfile.new("threatinator", encoding: "binary")
        while chunk = zio.read(10240)
          tempfile.write(chunk)
        end
        
        zio.close
        io.close unless io.closed?
        tempfile.rewind
        tempfile.set_encoding(self.encoding)
        tempfile
      rescue Zlib::GzipFile::Error => e
        raise Threatinator::Exceptions::DecoderError.new
      end

    end
  end
end
