require 'threatinator/config'
require 'threatinator/feed_registry'

module Threatinator
  module CLI
    class ActionBuilder
      attr_reader :extra_args, :config_hash

      def initialize(config_hash, extra_args)
        @extra_args = extra_args
        @config_hash = config_hash
        @feed_registry = nil
      end

      def build
        #:nocov:
        raise NotImplementedError.new("#{self.class}#build not implemented")
        #:nocov:
      end

      def feed_registry
        return @feed_registry unless @feed_registry.nil?

        feed_search_hash = config_hash["feed_search"] || {}
        feed_search_config = Threatinator::Config::FeedSearch.new(feed_search_hash)

        @feed_registry = Threatinator::FeedRegistry.build(feed_search_config)
      end
    end

  end
end

