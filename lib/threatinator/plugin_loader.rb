require 'rubygems'
require 'threatinator/util'

module Threatinator
  class PluginLoader
    def initialize()
      @plugins = {}
    end

    def load_all_plugins()
      load_plugins('*')
    end

    def load_plugins(type)
      load_files(find_plugin_files(type))
    end

    def [](type)
      @plugins[type] || {}
    end

    def types
      @plugins.keys
    end

    def register_plugin(type, name)
      plugin_name = "Threatinator::Plugins::#{Threatinator::Util.underscore2cc(type)}::#{Threatinator::Util.underscore2cc(name)}"
      begin
        type_obj = Threatinator::Plugins.const_get(Threatinator::Util.underscore2cc(type))
        plugin = type_obj.const_get(Threatinator::Util.underscore2cc(name))
        @plugins[type.to_sym] ||= {}
        @plugins[type.to_sym][name.to_sym] = plugin
      rescue ::NameError
        raise Threatinator::Exceptions::PluginLoadError.new("Failed to load plugin '#{plugin_name}'")
      end
    end

    def find_plugin_files(type)
      Gem.find_files("threatinator/plugins/#{type}/*.rb")
    end

    def load_files(file_names)
      file_names.each do |file_name|
        path, type, name = split_file_name(file_name)
        next if path.nil?
        begin 
          require path
        rescue ::LoadError
          next
        end

        register_plugin(type, name)
      end
    end

    # @return [Array, nil] an array containing the path, type, and name of the
    #  plugin
    def split_file_name(file_name)
      m = file_name.match(/(?<=(\A|\/))(?<path>threatinator\/plugins\/(?<type>[^\/]+)\/(?<name>[^\/\.]+))\.rb$/)
      return nil if m.nil?
      [m[:path], m[:type], m[:name]]
    end
  end
end
