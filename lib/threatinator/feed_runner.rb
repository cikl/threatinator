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
      @event_builder = Threatinator::EventBuilder.new(@feed)
      @feed_filters = @feed.filter_builders.map { |x| x.call } 
      @decoders = @feed.decoder_builders.map { |x| x.call } 
      @parser_block = @feed.parser_block
      @create_event_proc = @event_builder.create_event_proc()
      _init_feed_report()
    end

    def _init_feed_report()
      @feed_report = @feed_report_class.new
    end

    # @param [Hash] opts The options hash
    # @option opts [IO-like] :io Override the fetcher by providing 
    #  an IO directly. 
    # @option opts [Proc] :record_callback A callback that allows 
    # @option opts [Boolean] :skip_decoding (false) Skip all decoding if set 
    #  to true. Useful for testing.
    def run(opts = {})
      skip_decoding = !!opts.delete(:skip_decoding)
      unless io = opts.delete(:io)
        fetcher = @feed.fetcher_builder.call()
        io = fetcher.fetch()
      end

      unless skip_decoding == true
        @decoders.each do |decoder|
          io = decoder.decode(io)
        end
      end

      record_callback = opts.delete(:record_callback)

      _init_feed_report()

      parser = @feed.parser_builder.call()

      parser.run(io) do |record|
        rr = parse_record(record)
        unless record_callback.nil?
          record_callback.call(record, rr)
        end
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

    # Runs a feed
    # @param [Threatinator::Feed] feed The feed to run
    # @param [Threatinator::Output] output The output instance
    # @param [Hash] run_opts Options passed to #run. See #run .
    def self.run(feed, output, run_opts = {})
      self.new(feed, output).run(run_opts)
    end

  end
end
