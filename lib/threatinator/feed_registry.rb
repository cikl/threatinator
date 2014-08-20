require 'threatinator/registry'
require 'threatinator/feed_builder'

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

    def each
      return enum_for(:each) unless block_given?
      super do |key, feed|
        yield(feed)
      end
    end

    def register_from_file(filename)
      builder = Threatinator::FeedBuilder.from_file(filename)
      feed = builder.build
      register(feed)
      feed
    end

    # Builds a new FeedRegistry based on the provided config
    # @param [Threatinator::Config::FeedSearch] config The configuration
    def self.build(config)
      ret = self.new
      config.search_path.each do |path|
        pattern = File.join(path, "**", "*.feed")
        Dir.glob(pattern).each do |filename|
          ret.register_from_file(filename)
        end
      end
      ret
    end
  end
end
