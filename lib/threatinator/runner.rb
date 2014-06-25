require 'threatinator'
require 'threatinator/event_builder'
require 'threatinator/registry'
require 'threatinator/feed_builder'
require 'threatinator/feed_runner'
require 'threatinator/outputs/csv'

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

    def run(provider, name, output_builder, opts = {})
      _load_feeds()
      feed = @registry.get(provider, name)
      output_formatter = output_builder.build_for_feed(feed)
      feed_runner = Threatinator::FeedRunner.new(feed, output_formatter)
      feed_coverage = feed_runner.run(opts)
      require 'pp'
      pp [:filtered, feed_coverage.records_filtered.count, 
          :parsed, feed_coverage.records_parsed.count, 
          :missed, feed_coverage.records_missed.count]
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
