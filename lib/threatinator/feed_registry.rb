require 'threatinator/registry'

module Threatinator
  class FeedRegistry < Registry
    # @param [Threatinator::Feed] feed The feed to register
    # @raise [Threatinator::Exceptions::AlreadyRegisteredError] if a feed
    #  with the same name and provider is already registered.
    def register(feed)
      super([feed.provider, feed.name], feed)
    end

    # @param [String] provider
    # @param [String] name
    # @return [Threatinator::Feed]
    def get(provider, name)
      super([provider, name])
    end
  end
end
