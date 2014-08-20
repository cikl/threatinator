require 'threatinator/config/base'
require 'threatinator/exceptions'

module Threatinator
  module Actions
    module Run
      module OutputConfigClassMethods
        def set_plugin_loader(pl)
          @plugin_loader = pl
          pl.each(:output) do |type, name, plugin|
            self.attribute name, plugin::Config, default: lambda { |c,a| plugin::Config.new }
          end
        end

        def get_plugin(name)
          @plugin_loader.get(:output, name)
        end

        def formats
          @plugin_loader.each(:output).map { |t, k, p| k.to_s }
        end

        def formats_str
          formats.sort.join(', ')
        end

      end

      module OutputConfigMethods
        def build_output
          oc = self.class.get_plugin(self.format)
          if oc.nil?
            raise Threatinator::Exceptions::UnknownPlugin.new("Unknown output plugin: '#{format}'")
          end
          output_config = self[format]

          if output_config.nil?
            raise Threatinator::Exceptions::CouldNotFindOutputConfigError.new("Could not find output config for '#{format}'. Perhaps there's some load-order issues?")
          end

          oc.new(output_config)
        end
      end

      module OutputConfig
        def self.generate(plugin_loader)
          anonymous_class = Class.new(Threatinator::Config::Base) do
            extend OutputConfigClassMethods
            include OutputConfigMethods
            set_plugin_loader(plugin_loader)
            attribute :format, Symbol, default: lambda { |c,a| :csv },
              description: lambda { |c, a| "Output format (#{c.formats_str})" }
          end
          anonymous_class
        end
      end
    end
  end
end
