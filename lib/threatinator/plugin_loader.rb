require 'rubygems'
require 'threatinator/util'
require 'threatinator/registry'

module Threatinator
  class PluginLoader
    def initialize()
      @plugin_types_registry = Threatinator::Registry.new
    end

    # Loads all plugins
    # @return [Threatinator::PluginLoader] self
    def load_all_plugins()
      load_plugins(:*)
      return self
    end

    # Loads all plugins of the specified type
    # @param [#to_sym] type
    # @return [Threatinator::PluginLoader] self
    def load_plugins(type)
      load_files(find_plugin_files(type.to_sym))
      return self
    end

    # Retrieves a loaded plugin by type and name.
    # @param [#to_sym] type
    # @param [#to_sym] name
    # @return [Object] plugin
    def get(type, name)
      type_registry = @plugin_types_registry.get(type.to_sym)
      return nil if type_registry.nil?
      return type_registry.get(name.to_sym)
    end

    # Enumerates through all plugins, optionally filtered by type.
    # @yield [type, name, plugin]
    # @yieldparam [Symbol] type
    # @yieldparam [Symbol] name
    # @yieldparam [Object] plugin
    def each(type = nil)
      return enum_for(:each, type) unless block_given?
      @plugin_types_registry.each do |t, type_registry|
        unless type.nil?
          next unless type.to_sym == t
        end
        type_registry.each do |name, plugin|
          yield(t, name, plugin)
        end
      end
    end

    # Returns an array of all the types of plugins that are loaded.
    # @return [Array<Symbol>]
    def types
      @plugin_types_registry.keys
    end

    # Registers a plugin with the provided type and name.
    # @param [#to_sym] type
    # @param [#to_sym] name
    # @param [Object] plugin
    # @raise [Threatinator::Exceptions::AlreadyRegisteredError
    def register_plugin(type, name, plugin)
      type = type.to_sym
      unless type_registry = @plugin_types_registry.get(type)
        type_registry = @plugin_types_registry.register(type, Threatinator::Registry.new)
      end
      type_registry.register(name.to_sym, plugin)
    end

    private

    def find_plugin_files(type)
      Gem.find_files("threatinator/plugins/#{type}/*.rb")
    end

    def register_plugin_by_name(type, name)
      plugin_name = "Threatinator::Plugins::#{Threatinator::Util.underscore2cc(type)}::#{Threatinator::Util.underscore2cc(name)}"
      begin
        type_obj = Threatinator::Plugins.const_get(Threatinator::Util.underscore2cc(type))
        plugin = type_obj.const_get(Threatinator::Util.underscore2cc(name))
        register_plugin(type, name, plugin)
      rescue ::NameError => e
        raise Threatinator::Exceptions::PluginLoadError.new("Failed to load plugin '#{plugin_name}'", e)
      end
    end

    def load_files(file_names)
      file_names.each do |file_name|
        path, type, name = split_file_name(file_name)
        next if path.nil?
        # Don't try to load unit tests as plugins :)
        next if name.end_with?("_spec")
        begin 
          require path
        rescue ::LoadError
          # TODO: Handle plugins inside of gems a bit better. We should try 
          #  using only the latest version of a given Gem.
          next
        end

        register_plugin_by_name(type, name)
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
