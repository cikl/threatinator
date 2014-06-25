require 'threatinator/runner'
require 'threatinator/output_builder'
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

    def self.do_run_command(runner, opts, args)
      run_opts = {}
      provider = args.shift or raise "Missing provider"
      name = args.shift or raise "Missing name"
      return if opts[:dryrun] == true
      output_builder = create_output_builder(opts[:'output-format'], opts)
      if filename = opts[:"read-data-from-file"]
        puts "Opening #{filename}"
        run_opts[:io] = File.open(filename, "r")
      end

      runner.run(provider, name, output_builder, run_opts)
    ensure 
      run_opts[:io].close unless run_opts[:io].nil?
    end

    def self.create_output_builder(type, opts = {})
      builder = Threatinator::OutputBuilder.new
      case type
      when 'csv'
        require 'threatinator/outputs/csv'
        # TODO allow folks to specify the output IO
        builder.output_class Threatinator::Outputs::CSV
        builder.output_io $stdout
      when 'rubydebug'
        require 'threatinator/outputs/rubydebug'
        builder.output_class Threatinator::Outputs::Rubydebug
        builder.output_io $stdout
      when 'null'
        require 'threatinator/outputs/null'
        builder.output_class Threatinator::Outputs::Null
        builder.output_io $stdout
      else 
        raise ArgumentError.new("Unknown output format: #{type}")
      end
      return builder
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

          on '-r=', '--read-data-from-file', "Read data from the specified file rather than fetching"

          on '-f=', '--output-format', "Output format (csv, rubydebug, null)", as: String, default: 'csv'

          run do |slop, args|
            opts = slop.to_hash
            GlobalOptions.process!(runner, opts, args)
            Threatinator::CLI.do_run_command(runner, opts, args)
          end
        end # run
      
      
      
      end
    end
  end
end
