require 'threatinator/exceptions'
require 'threatinator/registry'

module Threatinator
  class PluginRegistry
    def initialize
      @output_plugins = Registry.new
    end

    def register_output(name, output_class)
      name = name.to_sym
      @output_plugins.register(name, output_class)
    end

    def get_output_by_name(output_name)
      ret = @output_plugins.get(output_name.to_sym)
      if ret.nil?
        raise Threatinator::Exceptions::UnknownPlugin.new("Unknown plugin: #{output_name}")
      end
      ret
    end
  end
end
