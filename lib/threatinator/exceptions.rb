module Threatinator
  module Exceptions
    # Indicates that a fetch failed.
    class FetchFailed < StandardError
    end
    
    # Indicates that the decode operation failed
    class DecoderError < StandardError
    end

    class ParseError < StandardError
    end

    class PluginLoadError < StandardError
    end

    class UnknownPlugin < StandardError
    end
    
    class InvalidAttributeError < StandardError
      attr_reader :attribute, :got
      def initialize(attribute, got)
        @attribute = attribute
        @got = got
        super("Invalid value for attribute '#{attribute}'. Got " + got.inspect)
      end
    end

    class AlreadyRegisteredError < StandardError
    end

    class UnknownFeed < StandardError
      attr_reader :provider, :name
      def initialize(provider, name)
        @provider = provider
        @name = name
        super("Failed to find feed with provider '#{provider}' and name '#{name}'")
      end
    end

    class FeedFileNotFoundError < StandardError
      def initialize(filename)
        @filename = filename
        super("Failed to open/read feed file '#{filename}'")
      end
    end
  end
end

