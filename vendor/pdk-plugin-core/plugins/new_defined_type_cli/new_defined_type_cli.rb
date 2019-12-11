require 'pdk/plugins'

module PDKCorePlugins
  class NewDefinedTypeCLIPlugin < PDK::CLIPlugin
    def initialize
      super('new_defined_type_cli')
    end

    def create_cri_command
      PDK::PluginManager.instance[:new_cli].cri_command.define_command do
        name 'defined_type'
        usage _('defined_type [options] <name>')
        summary _('Create a new defined type named <name> using given options')

        run do |opts, args, _cmd|
          PDK::CLI::Util.ensure_in_module!(
            message: _('Defined types can only be created from inside a valid module directory.'),
            log_level: :info,
          )

          defined_type_name = args[0]

          if defined_type_name.nil? || defined_type_name.empty?
            PDK.ui.puts command.help
            exit 1
          end

          unless PDK::CLI::Util::OptionValidator.valid_defined_type_name?(defined_type_name)
            raise PDK::CLI::ExitWithError, _("'%{name}' is not a valid defined type name") % { name: defined_type_name }
          end

          PDK::CLI::Util.analytics_screen_view('new_defined_type', opts)

          klass = PDK::Generate.generator_for_object_type(:defined_type)
          raise PDK::CLI::ExitWithError, _("Unable to find the defined_type generator") if klass.nil?
          gen = klass.new(defined_type_name, PDK::Util.module_root, opts)
          updates = gen.generate_to_disk
          PDK.logger.info("There was nothing to generate") unless updates.changes?
        end
      end
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::NewDefinedTypeCLIPlugin.new)
