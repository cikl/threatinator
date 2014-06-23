require 'docile'
require 'threatinator/feed'
require 'threatinator/feed_builder'
require 'threatinator/registry'

module Threatinator
  @registry = Threatinator::Registry.new

  # Build a feed using the feed builder DSL. 
  # @param [String] provider The name of the provider
  # @param [String] name The name of the feed
  # @return [Threatinator::Feed] the generated feed
  # @raise [StandardError] if the feed is not properly formed
  def self.build_feed(provider, name, &block)
    builder = Threatinator::FeedBuilder.new
    builder.provider provider
    builder.name name
    return Docile.dsl_eval(builder, &block).build
  end

  def self.register_feed_from_file(filename)
    begin 
      filedata = File.read(filename)
    rescue Errno::ENOENT
      raise Threatinator::Exceptions::FeedFileNotFoundError.new(filename)
    end
    builder = Threatinator::FeedBuilder.new
    feed = Docile.dsl_eval(builder) do
      eval(filedata, binding, filename)
    end.build
    register_feed(feed)
  end

  # @overload register_feed(provider_or_feed, name, &block)
  #   Builds and registers a feed.
  #   @param [String] provider_or_feed The name of the provider
  #   @param [String] name The name of the feed
  #   @return [Threatinator::Feed] the generated feed
  #   @raise [StandardError] if the feed is not properly formed
  #   @raise [Threatinator::Exceptions::FeedAlreadyRegisteredError] if the feed
  #    is already registered.
  #   @raise [ArgumentError] if the provider_or_feed is invalid
  # @overload register_feed(provider_or_feed)
  #   Registers a feed.
  #   @param [Threatinator::Feed] provider_or_feed The feed
  #   @return [Threatinator::Feed] the generated feed
  #   @raise [StandardError] if the feed is not properly formed
  #   @raise [Threatinator::Exceptions::FeedAlreadyRegisteredError] if the feed
  #    is already registered.
  #   @raise [ArgumentError] if the provider_or_feed is invalid
  #
  def self.register_feed(provider_or_feed, name = nil, &block)
    feed = case provider_or_feed
           when Threatinator::Feed
             provider_or_feed
           when String
             build_feed(provider_or_feed, name, &block)
           else
             raise ArgumentError.new("Invalid argument for provider_or_feed." +
                                     " Got #{provider_or_feed.class}")
           end
    self.registry.register(feed)
    feed
  end

  # The global registry
  # @return [Threatinator::Registry]
  def self.registry
    @registry
  end
end
