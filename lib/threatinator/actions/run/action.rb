require 'threatinator/action'
require 'threatinator/exceptions'
require 'threatinator/feed_runner'
require 'csv'

module Threatinator
  module Actions
    module Run
      class Action < Threatinator::Action
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
            raise Threatinator::Exceptions::UnknownFeed.new(@config.feed_provider, @config.feed_name)
          end

          output = build_output

          feed_runner = Threatinator::FeedRunner.new(feed, output)

          @config.observers.each do |observer|
            feed_runner.add_observer(observer)
          end

          feed_runner.run

#          if feed_report.num_records_missed != 0
#            $stderr.puts "WARNING: #{feed_report.num_records_missed} lines/records were MISSED (neither filtered nor parsed). You may need to update your feed specification! Rerun with --coverage to see which records are parsed/filtered/missed" 
#          end

        end
      end
    end
  end
end
