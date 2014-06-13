module Threatinator
  module Exceptions
    # Indicates that a fetch failed.
    class FetchFailed < StandardError
    end
    
    # Indicates an error during an IO operation
    class IOWrapperError < StandardError
    end
  end
end

