require 'threatinator/runner'
require 'threatinator/plugins'
require 'slop'
require 'pp'

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

    def self.build_output(name)
      if name.nil?
        raise Threatinator::Exceptions::UnknownPlugin.new("No output-format provided")
      end

      output_plugin_path = "threatinator/outputs/#{name}"
      begin
        require output_plugin_path
      rescue ::LoadError
        $stderr.puts "WARNING: failed to require '#{output_plugin_path}'"
      end

      klass = Threatinator::Plugins.get_output_by_name(name)
      klass.new()
    end

    def self.do_run_command(runner, opts, args)
      run_opts = {}
      provider = args.shift or raise "Missing provider"
      name = args.shift or raise "Missing name"
      return if opts[:dryrun] == true

      output_name = opts.delete(:'output-format')
      output = build_output(output_name)

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

      feed_report = runner.run(provider, name, output, run_opts)

      if coverage_filehandle
        $stderr.puts "Coverage report generated." 
        coverage_filehandle.close
      elsif feed_report.num_records_missed != 0
        $stderr.puts "WARNING: #{feed_report.num_records_missed} lines/records were MISSED (neither filtered nor parsed). You may need to update your feed specification! Rerun with --coverage to see which records are parsed/filtered/missed" 
      end
    ensure 
      run_opts[:io].close unless run_opts[:io].nil?
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
