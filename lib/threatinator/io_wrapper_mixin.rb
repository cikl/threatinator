require 'threatinator/exceptions'

module Threatinator
  # Expects a #to_io method
  module IOWrapperMixin
    def _handle_error
      begin
        yield
      rescue IOError => e
        raise Threatinator::Exceptions::IOWrapperError.new
      end
    end

    # Reads from the IO. 
    # @see ::IO
    def read(*args)
      _handle_error do
        self.to_io.read(*args)
      end
    end

    # Closes the io
    def close()
      _handle_error do 
        self.to_io.close
      end
    end

    # @return [Boolean] true if closed, false if not closed
    def closed?
      self.to_io.closed?
    end
  end
end

