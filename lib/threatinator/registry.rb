require 'threatinator/exceptions'

module Threatinator
  # Holds a set of threatinator feeds
  class Registry
    include Threatinator::Exceptions

    def initialize()
      @feeds = Hash.new
    end

    # @param [Threatinator::Feed]
    # @raise [Threatinator::Exceptions::FeedAlreadyRegisteredError] if a feed
    #  with the same name and provider is already registered.
    def register(feed)
      key = [feed.provider, feed.name]
      if @feeds.has_key?(key)
        raise FeedAlreadyRegisteredError.new(feed.provider, feed.name)
      end
      @feeds[key] = feed
    end

    # @param [String] provider
    # @param [String] name
    # @return [Threatinator::Feed]
    def get(provider, name)
      @feeds[[provider, name]]
    end

    # @return [Integer] the number of feeds in the registry
    def count
      @feeds.count
    end

    # Enumerates through each feed in our registry
    # @yield [feed]
    # @yieldparam [Threatinator::Feed] feed A feed within the registry
    def each(&block)
      @feeds.each_value(&block)
    end

    # Removes all feeds from the registry
    def clear
      @feeds.clear
    end
  end
end

