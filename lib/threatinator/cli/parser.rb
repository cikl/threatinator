require 'gli'
require 'threatinator/actions/run'
require 'threatinator/actions/list'
require 'threatinator/config/feed_search'
require 'threatinator/config/logger'
require 'threatinator/cli/list_action_builder'
require 'threatinator/cli/run_action_builder'
require 'threatinator/plugin_loader'

module Threatinator
  module CLI
    module Helpers
      def add_cli_args(gli, config_properties)
        config_properties.each do |key, args|
          desc, type, default_value = args
          if type.base == Axiom::Types::Boolean
            gli.switch key, desc: desc
          elsif type.base ==Axiom::Types::Array
            gli.flag key, desc: desc, type: Array
          else 
            gli.flag key, desc: desc
          end
        end
      end

      def clean_opts(opts)
        opts.delete_if {|k, v| k.kind_of?(::Symbol) or (k == 'help') or v.nil? }
        opts
      end

      def nest_opts(opts)
        config_hash = {}
        opts.each_pair do |key, val|
          key_path = key.to_s.split('.')
          final_key = key_path.pop
          nested_hash = config_hash
          while key_path.length > 0
            part = key_path.shift
            nested_hash[part] ||= {}
            nested_hash = nested_hash[part]
          end
          nested_hash[final_key] = val
        end
        config_hash
      end

      def fix_opts(opts)
        nest_opts(clean_opts(opts))
      end
    end

    class Parser
      include Helpers

      attr_accessor :builder
      attr_reader :config_hash, :extra_args
      attr_reader :run_action_config_class

      def initialize
        @builder = nil
        @plugin_loader = Threatinator::PluginLoader.new
        @plugin_loader.load_all_plugins
        @run_action_config_class = Threatinator::Actions::Run::Config.generate(@plugin_loader)
        @mod = _init_mod
      end

      def parse(args)
        @mod.run(args)
      end

      def set_opts(global_options, options, args)
        @config_hash = fix_opts(global_options.merge(options))
        @extra_args = args
      end

      def _init_mod
        parser = self
        Module.new do
          extend Helpers
          extend GLI::App

          program_desc 'Threatinator!'

          add_cli_args(self, Threatinator::Config::Logger.properties('logger'))
          add_cli_args(self, Threatinator::Config::FeedSearch.properties('feed_search'))

          desc "fetch and parse a feed"
          command :run do |c|
            c.flag 'run.coverage_output', type: String, desc: "Write coverage analysis to the specified file (CSV format)"

            add_cli_args(c, parser.run_action_config_class.properties('run'))
            c.action do |global_options, options, args|
              if options["run.feed_provider"].nil?
                options["run.feed_provider"] = args.shift
              end

              if options["run.feed_name"].nil?
                options["run.feed_name"] = args.shift
              end

              parser.set_opts(global_options, options, args)

              builder = Threatinator::CLI::RunActionBuilder.new(parser.config_hash, parser.extra_args, parser.run_action_config_class)
              parser.builder = builder
            end
          end

          desc 'list out all the feeds'
          command :list do |c|
            add_cli_args(c, Threatinator::Actions::List::Config.properties('list'))
            c.action do |global_options, options, args|
              parser.set_opts(global_options, options, args)
              parser.builder = Threatinator::CLI::ListActionBuilder.new(parser.config_hash, parser.extra_args)
            end
          end
        end
      end

    end # _init_mod
  end

end

