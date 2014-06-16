require 'threatinator/exceptions'

module Threatinator
  # Basic IOWrapper interface. 
  class IOWrapper
    # @param [Hash] opts A hash of options.
    def initialize(opts = {})
    end

    def io
      #:nocov:
      raise NotImplementedError.new("#{self.class}#io not implemented!")
      #:nocov:
    end

    public
    # Reads from the IO. Wraps _native_read with _handle_read_error so that 
    # exceptions may be translated.
    #
    # @param [Integer, nil] read_length (nil) The number of bytes, at most, to 
    #  read from the IO. If nil, all remaining data will be read.
    #
    # @return [String, nil] 
    #   If read_length is a positive integer, this returns a String contaiing 1 
    #    to read_length bytes of data. 
    #   
    #   If read_length is nil, returns all remaining data.
    #
    #   At end of file, it returns nil or "" depend on length. io.read() and 
    #    io.read(nil) returns "". io.read(positive-integer) returns nil.
    #
    # @raise [Threatinator::Exceptions::IOWrapperError] if any error is 
    #  encountered.
    #
    # @see http://ruby-doc.org/core-1.9.3/IO.html#method-i-read
    def read(read_length = nil)
      begin 
        _native_read(read_length)
      rescue => e
        e2 = _handle_read_error(e)
        raise e2 unless e2.nil?
      end
    end

    # Closes the IO. Wraps _native_close with _handle_close_error so that 
    #   exceptions may be translated.
    # @see ::IO
    def close()
      begin 
        _native_close()
      rescue => e
        e2 = _handle_close_error(e)
        raise e2 unless e2.nil?
      end
    end

    # @return [Boolean] true if closed, false if not closed
    def closed?
      io.closed?
    end

    # @return [Boolean] true if we are at the end of the file, false otherwise.
    def eof?
      io.eof?
    end

    protected

    # Translates from native exceptions to Threatinator exceptions.
    def _handle_error(e)
      case e
      when IOError
        Threatinator::Exceptions::IOWrapperError.new
      else
        e
      end
    end

    def _handle_read_error(e)
      _handle_error(e)
    end

    def _handle_close_error(e)
      _handle_error(e)
    end

    # Native/direct reading of io without exception translation.
    # @see IOWrapper#read
    def _native_read(read_length)
      io.read(read_length)
    end

    # Native/direct closing of io without exception translation.
    def _native_close()
      io.close
    end
  end
end

