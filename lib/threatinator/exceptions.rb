module Threatinator
  module Exceptions
    # Indicates that a fetch failed.
    class FetchFailed < StandardError
    end
    
    # Indicates an error during an IO operation
    class IOWrapperError < StandardError
    end

    class InvalidAttributeError < StandardError
      def initialize(attribute, expected, got)
        @attribute = attribute
        @expected = expected
        @got = got
        super("Invalid value for attribute '#{attribute}'. Expected a '#{expected}', got " + got.class().to_s)
      end
    end
  end
end

