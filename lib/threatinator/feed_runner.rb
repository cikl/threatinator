require 'threatinator/event_builder'
require 'threatinator/instrumentation/feed'

module Threatinator
  # Runs those feeds!
  class FeedRunner

    # @param [Threatinator::Feed] feed The feed that we want to run.
    def initialize(feed, output_formatter)
      @feed = feed
      @output_formatter = output_formatter
      @event_builder = Threatinator::EventBuilder.new
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
        puts "FETCHING!"
        fetched_io = _fetch()
      end

      parser = _init_parser(fetched_io)

      filters = @feed.filters
      parser_block = @feed.parser_block
      create_event_proc = @event_builder.create_event_proc()

      feed_coverage = Threatinator::Instrumentation::Feed.new(@feed)

      parser.each do |*args|
        record_coverage = feed_coverage.add_record(args)
        if filters.any? { |filter| filter.filter?(*args) }
          record_coverage.filtered!
          next
        end
        args.unshift(create_event_proc)
        parser_block.call(*args)
        if @event_builder.count == 0
          # Keep track of the fact that this line did not generate any events?
        else 
          @event_builder.each_built_event do |event|
            record_coverage.add_event(event)
            @output_formatter.handle_event(event)
          end
          @event_builder.clear
        end
      end

      feed_coverage
    end

  end
end
