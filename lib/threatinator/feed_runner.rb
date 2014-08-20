require 'threatinator/event_builder'
require 'observer'

module Threatinator
  # Runs those feeds!
  #
  #  Has the following observations:
  #    :start                 - start of feed parsing
  #
  #    :start_fetch           - start of fetching
  #    :end_fetch             - end of fetching
  #
  #    :start_decode          - start of decoding
  #    :end_decode            - end of decoding
  #
  #    :start_parse_record    - start of record parse
  #       - record                - The record
  #
  #    :record_filtered       - Indicates that the record was filtered.
  #       - record                - The record
  #
  #    :record_missed         - Indicates that the record was not parsed
  #       - record                - The record
  #
  #    :record_parsed         - Indicates that the record WAS parsed
  #       - record                - The record
  #       - events                - The events that were parsed out of the 
  #                                 record
  #
  #    :end_parse_record      - when a record has been parsed
  #       - record                - The record
  #
  #    :end                   - completion of feed parsing
  #
  class FeedRunner
    include Observable

    # @param [Threatinator::Feed] feed The feed that we want to run.
    # @param [Threatinator::Output] output_formatter
    def initialize(feed, output_formatter, opts = {})
      @feed = feed
      @output_formatter = output_formatter
      @event_builder = Threatinator::EventBuilder.new(@feed)
      @feed_filters = @feed.filter_builders.map { |x| x.call } 
      @decoders = @feed.decoder_builders.map { |x| x.call } 
      @parser_block = @feed.parser_block
      @create_event_proc = @event_builder.create_event_proc()
    end

    # @param [Hash] opts The options hash
    # @option opts [IO-like] :io Override the fetcher by providing 
    #  an IO directly. 
    # @option opts [Boolean] :skip_decoding (false) Skip all decoding if set 
    #  to true. Useful for testing.
    def run(opts = {})
      changed(true); notify_observers(:start)
      skip_decoding = !!opts.delete(:skip_decoding)

      unless io = opts.delete(:io)
        fetcher = @feed.fetcher_builder.call()
        changed(true); notify_observers(:start_fetch)
        io = fetcher.fetch()
        changed(true); notify_observers(:end_fetch)
      end

      unless skip_decoding == true
        changed(true); notify_observers(:start_decode)
        @decoders.each do |decoder|
          io = decoder.decode(io)
        end
        changed(true); notify_observers(:end_decode)
      end

      parser = @feed.parser_builder.call()

      parser.run(io) do |record|
        rr = parse_record(record)
      end

      changed(true); notify_observers(:end)
      nil
    end

    def parse_record(record)
      @event_builder.clear
      events = []
      changed(true); notify_observers(:start_parse_record, record)

      if @feed_filters.any? { |filter| filter.filter?(record) }
        changed(true); notify_observers(:record_filtered, record)
        return
      end
      @parser_block.call(@create_event_proc, record)
      if @event_builder.count == 0
        changed(true); notify_observers(:record_missed, record)
        # Keep track of the fact that this line did not generate any events?
      else 
        @event_builder.each_built_event do |event|
          events << event
          @output_formatter.handle_event(event)
        end
        changed(true); notify_observers(:record_parsed, record, events)
      end
      return
    ensure 
      changed(true); notify_observers(:end_parse_record, record)
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
