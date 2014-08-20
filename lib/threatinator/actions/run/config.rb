require 'threatinator/config/base'
require 'threatinator/actions/run/output_config'

module Threatinator
  module Actions
    module Run
      module Config
        # @param [Threatinator::PluginLoader] plugin_loader
        # @return [Class] a class that represents the config for Action::Run
        def self.generate(plugin_loader)
          output_config_class = Threatinator::Actions::Run::OutputConfig.generate(plugin_loader)
          config_class = Class.new(Threatinator::Config::Base) do
            attribute :output, output_config_class, 
              default: lambda { |c,a| output_config_class.new }

            attribute :feed_provider, String, 
              description: "The feed provider" 

            attribute :feed_name, String, 
              description: "The feed name" 

            attribute :fetch_from_file, String, 
              description: "Read data from the specified file rather than fetching"

            attribute :observers, Array, default:  lambda {|c,a| Array.new }
          end
          config_class
        end
      end
    end
  end
end
