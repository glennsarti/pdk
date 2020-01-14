require 'pdk'

module PDKCorePlugins
  class NewClassCLIPlugin < PDK::PluginTypes::CLI
    def initialize
      super('new_class_cli')
    end

    def create_cri_command
      PDK::PluginManager.instance[:new_cli].cri_command.define_command do
        name 'class'
        usage _('class [options] <class_name>')
        summary _('Create a new class named <class_name> using given options')

        run do |opts, args, _cmd|
          PDK::CLI::Util.ensure_in_module!(
            message:   _('Classes can only be created from inside a valid module directory.'),
            log_level: :info,
          )

          class_name = args[0]

          if class_name.nil? || class_name.empty?
            PDK.ui.puts command.help
            exit 1
          end

          unless PDK::CLI::Util::OptionValidator.valid_class_name?(class_name)
            raise PDK::CLI::ExitWithError, _("'%{name}' is not a valid class name") % { name: class_name }
          end

          PDK::CLI::Util.analytics_screen_view('new_class', opts)

          klass = PDK::Generate.generator_for_object_type(:class)
          raise PDK::CLI::ExitWithError, _("Unable to find the class generator") if klass.nil?
          gen = klass.new(class_name, PDK::Util.module_root, opts)
          updates = gen.generate_to_disk
          PDK.logger.info("There was nothing to generate") unless updates.changes?
        end
      end
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::NewClassCLIPlugin.new)
