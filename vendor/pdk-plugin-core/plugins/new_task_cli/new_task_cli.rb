require 'pdk/plugins'

module PDKCorePlugins
  class NewTaskCLIPlugin < PDK::CLIPlugin
    def initialize
      super('new_task_cli')
    end

    def create_cri_command
      PDK::PluginManager.instance[:new_cli].cri_command.define_command do
        name 'task'
        usage _('task [options] <name>')
        summary _('Create a new task named <name> using given options')

        option nil, :description, _('A short description of the purpose of the task'), argument: :required

        run do |opts, args, _cmd|
          PDK::CLI::Util.ensure_in_module!(
            message:   _('Tasks can only be created from inside a valid module directory.'),
            log_level: :info,
          )

          task_name = args[0]
          module_dir = Dir.pwd

          if task_name.nil? || task_name.empty?
            PDK.ui.puts command.help
            exit 1
          end

          unless PDK::CLI::Util::OptionValidator.valid_task_name?(task_name)
            raise PDK::CLI::ExitWithError, _("'%{name}' is not a valid task name") % { name: task_name }
          end

          PDK::CLI::Util.analytics_screen_view('new_task', opts)

          klass = PDK::Generate.generator_for_object_type(:task)
          raise PDK::CLI::ExitWithError, _("Unable to find the task generator") if klass.nil?
          gen = klass.new(task_name, PDK::Util.module_root, opts)
          updates = gen.generate_to_disk
          PDK.logger.info("There was nothing to generate") unless updates.changes?
        end
      end
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::NewTaskCLIPlugin.new)
