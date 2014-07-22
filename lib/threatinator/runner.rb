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
    end

    def add_feed_path(path) 
      @feed_paths << path
    end

    def feed_paths
      @feed_paths
    end

    def list(opts = {})
      io_out = opts[:io_out] || $stdout
      io_err = opts[:io_err] || $stderr
      _load_feeds()
      feed_info = [['provider', 'name', 'type', 'link/path']]
      @registry.each do |feed|
        info = [ feed.provider, feed.name ]
        fetcher = feed.fetcher_builder.call()
        type = "unknown"
        link = "unknown"
        case fetcher
        when Threatinator::Fetchers::Http
          type = "http"
          link = fetcher.url
        end
        info << type
        info << link
        feed_info << info
      end
      return if feed_info.count == 0
      fmts = []
      widths = []
      0.upto(3) do |i|
        max = feed_info.max { |a,b| a[i].length <=> b[i].length }[i].length
        widths << max
        fmts << "%#{max}s"
      end
      fmt = "%-#{widths[0]}s  %-#{widths[1]}s  %-#{widths[2]}s  %-#{widths[3]}s\n"
      io_out.printf(fmt, *(feed_info.shift))
      sep = widths.map {|x| '-' * x }
      io_out.printf(fmt, *sep)
      feed_info.sort! { |a,b| [a[0], a[1]] <=> [b[0], b[1]] }
      feed_info.each  do |info|
        io_out.printf(fmt, *info)
      end
      io_out.printf(fmt, *sep)
      io_out.puts("Total: #{feed_info.count}")
    end

    def run(provider, name, output_builder, opts = {})
      _load_feeds()
      feed = @registry.get(provider, name)
      output_formatter = output_builder.build_for_feed(feed)
      feed_runner = Threatinator::FeedRunner.new(feed, output_formatter)
      feed_report = feed_runner.run(opts)
      return feed_report
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
