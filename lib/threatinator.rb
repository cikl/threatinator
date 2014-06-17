require 'docile'
require 'threatinator/feed_builder'

module Threatinator
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
end
