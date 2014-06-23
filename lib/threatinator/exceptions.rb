module Threatinator
  module Exceptions
    # Indicates that a fetch failed.
    class FetchFailed < StandardError
    end
    
    # Indicates an error during an IO operation
    class IOWrapperError < StandardError
    end

    class InvalidAttributeError < StandardError
      attr_reader :attribute, :expected, :got
      def initialize(attribute, expected, got)
        @attribute = attribute
        @expected = expected
        @got = got
        super("Invalid value for attribute '#{attribute}'. Expected a '#{expected}', got " + got.class().to_s)
      end
    end

    class FeedAlreadyRegisteredError < StandardError
      attr_reader :provider, :name
      def initialize(provider, name)
        @provider = provider
        @name = name
        super("provider: #{@provider}, name: #{@name}")
      end
    end

    class FeedFileNotFoundError < StandardError
      def initialize(filename)
        @filename = filename
        super("Failed to open/read feed file #{filename}")
      end
    end
  end
end

