require 'threatinator/event_builder'
require 'threatinator/instrumentation/feed_report'
require 'threatinator/instrumentation/record_report'

module Threatinator
  # Runs those feeds!
  class FeedRunner

    # @param [Threatinator::Feed] feed The feed that we want to run.
    # @param [Threatinator::Output] output_formatter
    def initialize(feed, output_formatter, opts = {})
      @feed = feed
      @feed_report_class = opts[:feed_report_class] || Threatinator::Instrumentation::FeedReport 
      @output_formatter = output_formatter
      @event_builder = Threatinator::EventBuilder.new
      @feed_filters = @feed.filters
      @parser_block = @feed.parser_block
      @create_event_proc = @event_builder.create_event_proc()
      _init_feed_report()
    end

    def _init_fetcher()
      @feed.fetcher_class.new(@feed.fetcher_opts)
    end

    def _init_feed_report()
      @feed_report = @feed_report_class.new
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

      _init_feed_report()

      parser = _init_parser(fetched_io)

      parser.each do |record|
        parse_record(record)
      end

      @feed_report
    end

    def parse_record(record)
      @event_builder.clear
      rr = @feed_report.wrap_record(record)
      if @feed_filters.any? { |filter| filter.filter?(record) }
        rr.filtered!
        return rr
      end
      @parser_block.call(@create_event_proc, record)
      if @event_builder.count == 0
        # Keep track of the fact that this line did not generate any events?
      else 
        @event_builder.each_built_event do |event|
          rr.add_event(event)
          @output_formatter.handle_event(event)
        end
      end
      return rr
    ensure 
      @feed_report.add_record_report(rr)
    end

  end
end
