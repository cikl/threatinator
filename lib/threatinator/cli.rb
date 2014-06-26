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
      coverage_filename = opts[:coverage]
      coverage_filehandle = nil
      unless coverage_filename.nil?
        coverage_filehandle = File.open(coverage_filename, "w")
        $stderr.puts "Writing coverage report to '#{coverage_filename}'"
        csv = ::CSV.new(coverage_filehandle, :headers => [:status, :event_count, :line_number, :pos_start, :pos_end, :data], :write_headers => true)
        record_callback = lambda do |record, rr|
          csv.add_row([rr.status, rr.event_count, record.line_number, record.pos_start, record.pos_end, record.data.inspect])
        end
        run_opts[:record_callback] = record_callback
      end
      if filename = opts[:"read-data-from-file"]
        puts "Opening #{filename}"
        run_opts[:io] = File.open(filename, "r")
      end

      feed_report = runner.run(provider, name, output_builder, run_opts)
      if coverage_filehandle
        $stderr.puts "Coverage report generated." 
        coverage_filehandle.close
      elsif feed_report.num_records_missed != 0
        $stderr.puts "WARNING: #{feed_report.num_records_missed} lines/records were MISSED (neither filtered nor parsed). You may need to update your feed specification! Rerun with --coverage to see which records are parsed/filtered/missed" 
      end
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

          on '--coverage=', "Write coverage analysis to the specified file (CSV format)", as: String

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
