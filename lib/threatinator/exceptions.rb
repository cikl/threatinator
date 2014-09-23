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
      attr_reader :cause
      def initialize(message, cause = nil)
        @cause = cause
        unless cause.nil?
          message = "#{message} : #{cause.class} : #{cause}"
          self.set_backtrace cause.backtrace
        end
        super(message)
      end
    end

    class UnknownPlugin < StandardError
    end

    class CouldNotFindOutputConfigError < StandardError
    end
    
    class InvalidAttributeError < StandardError
    end

    class EventBuildError < StandardError
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

