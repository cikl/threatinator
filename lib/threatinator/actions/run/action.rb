require 'threatinator/action'
require 'threatinator/exceptions'
require 'threatinator/feed_runner'
require 'threatinator/logging'
require 'threatinator/actions/run/status_observer'
require 'csv'

module Threatinator
  module Actions
    module Run
      class Action < Threatinator::Action
        include Logging

        def initialize(registry, config)
          super(registry)
          @config = config
        end

        def build_output
          @config.output.build_output
        end

        def exec
          opts = {}

          feed = registry.get(@config.feed_provider, @config.feed_name)
          if feed.nil?
            logger.error("Unknown feed: provider = #{@config.feed_provider}, name = #{@config.feed_name}")
            raise Threatinator::Exceptions::UnknownFeed.new(@config.feed_provider, @config.feed_name)
          end

          output = build_output

          feed_runner = Threatinator::FeedRunner.new(feed, output)
          status = StatusObserver.new
          feed_runner.add_observer(status)

          @config.observers.each do |observer|
            feed_runner.add_observer(observer)
          end

          feed_runner.run

          if status.missed?
            logger.error "#{status.missed} records were MISSED (neither parsed nor filtered). You may need to update your feed specification! Try increasing the logging level to DEBUG, or re-run with run.coverage_output='output.csv' to see which records were parsed/filtered/missed."
          end

          if status.errors?
            logger.error "#{status.errors} records had errors! You may have a bug in your feed specification! Try increasing the logging level to DEBUG, or re-run with run.coverage_output='output.csv' to see which records had errors."
          end

          logger.info "#{status.total} records processed. #{status.parsed} parsed, #{status.filtered} filtered, #{status.missed} missed, #{status.errors} errors"
        end
      end
    end
  end
end
