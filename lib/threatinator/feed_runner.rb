module Threatinator
  # Runs those feeds!
  class FeedRunner

    # @param [Threatinator::Feed] feed The feed that we want to run.
    def initialize(feed)
      @feed = feed
    end

    def _init_fetcher()
      @feed.fetcher_class.new(@feed.fetcher_opts)
    end

    def _fetch()
      fetcher = _init_fetcher()
      return fetcher.fetch()
    end

    def _init_parser(fetched_io)
      @feed.parser_class.new(fetched_io, @feed.parser_opts)
    end

    # @param [Hash] opts The options hash
    # @option opts [IO-like] :io Override the fetcher by providing 
    #  an IO directly. 
    def run(opts = {})
      unless fetched_io = opts.delete(:io)
        fetched_io = _fetch()
      end

      parser = _init_parser(fetched_io)

      filters = @feed.filters
      parser_block = @feed.parser_block

      entry_builder = nil
      parser.each do |*args|
        next if filters.any? { |filter| filter.filter?(*args) }
        args.unshift(entry_builder)
        parser_block.call(*args)
      end
    end
  end
end
