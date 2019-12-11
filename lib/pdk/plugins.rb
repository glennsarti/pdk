require 'singleton'

# TODO: Perhaps https://github.com/TwP/little-plugger/blob/master/lib/little-plugger.rb ?

module PDK
  class Plugin
    attr_reader :name

    def initialize(name)
      @name = name.to_s
      @activated = false
    end

    def plugin_metadata
      @plugin_metadata ||= PDK::PluginManager.instance.plugin_metadata(name)
    end

    def plugin_dependencies
      return [] if plugin_metadata['dependencies'].nil?
      plugin_metadata['dependencies']
    end

    def activated?
      @activated
    end

    def activate!
      @activated = true
# DEBUG
puts("Activated PDK Plugin #{name}")
    end
  end

  class CLIPlugin < Plugin
    attr_reader :cri_command

    def initialize(name)
      super(name)
      @cri_command = nil
    end

    def activate!
      return if activated?
      @cri_command = create_cri_command
      super()
    end

    # @abstract
    def create_cri_command
      raise "create_cri_command must be implemented in #{self.class}"
    end

    private

    def base_cri_command
      # TODO: This is a bit ugly for now
      PDK::CLI.instance_variable_get(:@base_cmd)
    end
  end

  class ValidatorPlugin < Plugin
    # @abstract
    # @return [Class] That inherits from PDK::Validate::BaseValidator
    def validator_klass; end
  end

  class LoggerPlugin < Plugin
    # @abstract
    # @return [Class] That inherits from ::Logger
    def logger_klass; end
  end

  class UIPlugin < Plugin
    # @abstract
    # @return [Class] That inherits from ::Logger
    def ui_klass; end
  end

  class GeneratorPlugin < Plugin
    attr_reader :object_type

    attr_reader :puppet_strings_type

    # @abstract
    # @return [Class] That inherits from ::Logger
    def generator_klass; end

    def activate!
      return if activated?
      instance = generator_klass.new
      @object_type = instance.object_type
      @puppet_strings_type = instance.puppet_strings_type
      super
    end
  end

  class PluginManager
    include Singleton

    def initialize
      @plugins_metadata = {}
      @plugins = {}
    end

    def find_all_plugins
      plugin_directories.each do |root_plugin_dir|
        Dir.glob(File.join(root_plugin_dir, '*/pdk-plugin.json')) do |metadata_path|
          metadata = JSON.parse(File.open(metadata_path, 'rb:UTF-8') { |f| f.read })
          metadata['plugin_filename'] = metadata_path
          metadata['plugin_path'] = File.dirname(metadata_path)

          if @plugins_metadata[metadata['name']]
            puts ("#{metadata['name']} plugin is duplicated by #{metadata_path}") # TODO : How to log this?
          else
            @plugins_metadata[metadata['name']] = metadata
          end
        end
      end
      nil
    end

    def register(plugin, raise_on_reregister = true)
      raise "Wrong object type" unless plugin.is_a?(PDK::Plugin)
      raise "Unknown plugin name #{plugin.name}" if @plugins_metadata[plugin.name].nil?
      unless @plugins[plugin.name].nil?
        raise "#{plugin.name} is already registered" if raise_on_reregister
puts ("#{plugin.name} is already registered") # TODO : How to log this?
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

          if plugins_activated(plugin.plugin_dependencies)
            activations += 1
            plugin.activate!
          end
        end
        break if activations.zero?
      end

      unactivated = @plugins.select { |name, plugin| plugin_names.include?(name) && !plugin.activated? }
      return if unactivated.empty?
  puts ("The plugin/s #{unactivated.keys.join(', ')} could not be activated") # TODO : How to log this?
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

    def plugins_activated(plugin_names)
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
