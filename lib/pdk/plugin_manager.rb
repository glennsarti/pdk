require 'singleton'
# We don't need to use autoloader here because this is absolutely required.
require 'pdk/plugin_types/plugin'

module PDK
  module PluginTypes
    autoload :Builder,   'pdk/plugin_types/builder'
    autoload :CLI,       'pdk/plugin_types/cli'
    autoload :Generator, 'pdk/plugin_types/generator'
    autoload :Logger,    'pdk/plugin_types/logger'
    autoload :UI,        'pdk/plugin_types/ui'
    autoload :Validator, 'pdk/plugin_types/validator'
  end
end

# TODO: Perhaps https://github.com/TwP/little-plugger/blob/master/lib/little-plugger.rb ?

module PDK
  class PluginManager
    include Singleton

    attr_reader :logger

    def initialize
      @plugins_metadata = {}
      @plugins = {}

      require 'logger'
      @logger = ENV['PDK_PLUGIN_DEBUG'].nil? ? ::Logger.new(File.open(File::NULL, 'w')) : ::Logger.new($stdout)
    end

    def find_all_plugins
      plugin_directories.each do |root_plugin_dir|
        Dir.glob(File.join(root_plugin_dir, '*/pdk-plugin.json')) do |metadata_path|
          metadata = JSON.parse(File.open(metadata_path, 'rb:UTF-8') { |f| f.read })
          metadata['plugin_filename'] = metadata_path
          metadata['plugin_path'] = File.dirname(metadata_path)

          if @plugins_metadata[metadata['name']]
            logger.warn("#{metadata['name']} plugin is duplicated by #{metadata_path}") # TODO : How to log this?
          else
            @plugins_metadata[metadata['name']] = metadata
          end
        end
      end
      nil
    end

    def register(plugin, raise_on_reregister = true)
      raise "Wrong object type" unless plugin.is_a?(PDK::PluginTypes::Plugin)
      raise "Unknown plugin name #{plugin.name}" if @plugins_metadata[plugin.name].nil?
      unless @plugins[plugin.name].nil?
        raise "#{plugin.name} is already registered" if raise_on_reregister
        logger.error("#{plugin.name} is already registered") # TODO : How to log this?
        return
      end

      @plugins[plugin.name] = plugin
    end

    def activate_plugins!(plugin_names)
      return if plugin_names.nil? || plugin_names.empty?

      loop do
        activations = 0
        plugin_names.each do |plugin_name|
          plugin = load_plugin(plugin_name)
          raise "#{plugin_name} is not a registered plugin" if plugin.nil?
          next if plugin.activated?

          if plugins_activated?(plugin.plugin_dependencies)
            activations += 1
            plugin.activate!
          end
        end
        break if activations.zero?
      end

      unactivated = @plugins.select { |name, plugin| plugin_names.include?(name) && !plugin.activated? }
      return if unactivated.empty?
      logger.error("The plugin/s #{unactivated.keys.join(', ')} could not be activated") # TODO : How to log this?
    end

    # TODO: Private
    def load_plugin(plugin_name)
      plugin = @plugins[plugin_name]
      return plugin unless plugin.nil?

      metadata = plugin_metadata(plugin_name)
      raise "Can not load #{plugin_name} as the metadata does not exist" if metadata.nil?
      file_path = File.join(metadata['plugin_path'], metadata['root_file'])
      require_relative file_path

      plugin = @plugins[plugin_name]
      raise "Plugin #{plugin_name} loaded but did not register a plugin" if plugin.nil?
      plugin
    end

    def plugins_activated?(plugin_names)
      return true if plugin_names.nil? || plugin_names.empty?
      plugin_names.each do |plugin_name|
        plugin = @plugins[plugin_name]
        return false if plugin.nil?           # Not yet registered
        return false unless plugin.activated? # Not yet activated
      end
      true
    end

    def activate_plugin_type!(plugin_type)
      activate_plugins!(plugin_names_from_type(plugin_type))
    end

    def plugin_names_from_type(plugin_type)
      @plugins_metadata.select { |_, plugin| plugin['plugin_type'] == plugin_type }.keys
    end

    def plugin_metadata(plugin_name)
      return if plugin_name.nil?
      @plugins_metadata[plugin_name]
    end

    def [](plugin_name)
      return if plugin_name.nil?
      @plugins[plugin_name.dup.to_s]
    end

    def plugin_gemspecs
      @plugin_gemspecs ||= Gem::Specification.select { |spec| spec.name =~ /pdk\-plugin\-/ }
    end

    def plugin_directories
      return @plugin_directories unless @plugin_directories.nil?

      # Find the core plugin.  It's special and should always be first
      core_plugin = plugin_gemspecs.find { |spec| spec.name == 'pdk-plugin-core' }
      raise "Could not find the pdk-plugin-core gem" if core_plugin.nil?
      @plugin_directories = [core_plugin.gem_dir]

      # Find the other plugins
      plugin_gemspecs.select { |spec| spec.name != 'pdk-plugin-core' }.each { |spec| @plugin_directories << spec.gem_dir }

      # Convert the gem dirs into the plugin directory
      @plugin_directories.map! { |dir| File.expand_path(File.join(dir, 'plugins')) }

      # Remove directories that don't exist
      @plugin_directories.reject! { |dir| !Dir.exist?(dir) }

      @plugin_directories.freeze
    end
  end
end
