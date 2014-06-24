require 'threatinator/runner'
require 'slop'

module Threatinator
  module CLI
    DEFAULT_FEED_PATH = File.expand_path("../../../feeds", __FILE__)
    module GlobalOptions
      def self.add(command)
        command.on '-n', 'dryrun', 'Parse options, but make no changes'
        command.on '-x', 'exclude-default-path', 
          'Exclude default path from feed search path'

        command.on '-p=', 'path', 
          'Add a path to the feed search path', as: Array, default: []
      end

      def self.process!(runner, opts, args)
        opts[:path].each do |path|
          runner.add_feed_path path
        end
        unless opts[:'exclude-default-path'] == true
          runner.add_feed_path DEFAULT_FEED_PATH
        end
        nil
      end
    end

    def self.process!(cli_args, runner)
      opts = Slop.parse!(cli_args, help: true, strict: true) do
        command 'list' do
          GlobalOptions.add(self)
          description "list stuff"

          run do |slop, args|
            opts = slop.to_hash
            GlobalOptions.process!(runner, opts, args)
            unless opts[:dryrun] == true
              runner.list(opts)
            end
          end

        end

        command 'run' do
          GlobalOptions.add(self)
          description "processes a feed"
          run do |slop, args|
            opts = slop.to_hash
            GlobalOptions.process!(runner, opts, args)
            provider = args.shift or raise "Missing provider"
            name = args.shift or raise "Missing name"
            unless opts[:dryrun] == true
              runner.run(provider, name)
            end
          end
        end
      end
    end
  end
end
