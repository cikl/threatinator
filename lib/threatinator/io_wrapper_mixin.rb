require 'threatinator/exceptions'

module Threatinator
  # Basic IOWrapper interface. Expects a #to_io method to be implemented.
  module IOWrapperMixin
    public
    # Reads from the IO. Wraps _native_read with _handle_error so that 
    # exceptions may be translated.
    # @see ::IO
    def read(*args)
      begin 
        _native_read(*args)
      rescue => e
        e2 = _handle_read_error(e)
        raise e2 unless e2.nil?
      end
    end

    # Closes the IO. Wraps _native_close with _handle_error so that exceptions 
    # may be translated.
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
      self.to_io.closed?
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
      _handle_error(3)
    end

    # Native/direct reading of io without exception translation.
    def _native_read(*args)
      self.to_io.read(*args)
    end

    # Native/direct closing of io without exception translation.
    def _native_close()
      self.to_io.close
    end
  end
end

