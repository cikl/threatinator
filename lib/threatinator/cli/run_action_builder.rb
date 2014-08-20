require 'threatinator/cli/action_builder'
require 'threatinator/actions/run'
require 'threatinator/actions/run/coverage_observer'
require 'csv'

module Threatinator
  module CLI
    class RunActionBuilder < ActionBuilder
      def initialize(opts, args, config_class)
        super(opts, args)
        @config_class = config_class
      end

      def build
        Threatinator::Actions::Run::Action.new(feed_registry, config)
      end

      def config
        run_hash = config_hash["run"] || {}
        run_hash['observers'] ||= []

        if filename = run_hash['coverage_output']
          observer = Threatinator::Actions::Run::CoverageObserver.new(filename)
          run_hash['observers'] << observer
        end

        config = @config_class.new(run_hash)

        if config.feed_provider.nil? && provider = extra_args.shift
          config.feed_provider = provider
        end

        if config.feed_name.nil? && name = extra_args.shift
          config.feed_name = name
        end
        config
      end

    end
  end
end
