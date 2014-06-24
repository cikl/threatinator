require 'threatinator'
require 'threatinator/registry'
require 'threatinator/feed_builder'
require 'threatinator/feed_runner'

module Threatinator
  # Runs all things Threatinator.
  class Runner
    attr_reader :registry

    # @param 
    def initialize
      @feed_paths = []
      @registry = Threatinator::Registry.new
      @io_out = $stdout
      @io_err = $stderr
    end

    def add_feed_path(path) 
      @feed_paths << path
    end

    def feed_paths
      @feed_paths
    end

    def list(opts = {})
      _load_feeds()
      @registry.each do |feed|
        @io_out.puts [feed.provider, feed.name].join("\t")
      end
    end

    def run(provider, name)
      _load_feeds()
      feed = @registry.get(provider, name)
      feed_runner = Threatinator::FeedRunner.new(feed)
      feed_runner.run()
    end

    def _register_feed_from_file(filename)
      builder = Threatinator::FeedBuilder.from_file(filename)
      feed = builder.build
      @registry.register(feed)
      feed
    end

    # Recursively loads and registers feeds from all paths contained in 
    # settings.feed_path array.
    def _load_feeds
      @feed_paths.each do |feed_path|
        pattern = File.join(feed_path, "**", "*.feed")
        Dir.glob(pattern).each do |filename|
          _register_feed_from_file(filename)
        end
      end
      nil
    end

  end
end
