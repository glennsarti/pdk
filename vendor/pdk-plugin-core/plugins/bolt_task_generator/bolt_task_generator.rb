require 'pdk'

module PDK
  module Generate
    class BoltTaskGenerator < PuppetModuleThingGenerator
      def object_type
        :task
      end

      def validation_errors
        errors = super

        # Checks that the task has not already been defined with a different extension.
        allowed_extensions = %w[.md .conf]
        PDK::Util::Filesystem.glob(File.join(root_path, 'tasks', "#{actual_object_name}.*")).each do |file|
          next if allowed_extensions.include?(File.extname(file))

          errors << _("A task named '%{name}' already exists in this module; defined in %{file}") % { name: actual_object_name, file: file }
        end

        errors
      end

      def template_data
        {
          name:                actual_object_name,
          puppet_task_version: 1,
          supports_noop:       false,
          description:         options.fetch(:description, 'A short description of this task'),
          parameters:          {},
        }
      end

      def template_files
        task_bash_path = File.join(root_path, 'tasks', actual_object_name + '.sh')
        task_metadata_path = File.join(root_path, 'tasks', actual_object_name + '.json')
        task_metadata = template_data.dup
        task_metadata.delete(:name)

        {
          task_bash_path     => PDK::TemplateFile.new(File.join(__dir__, 'task.sh.erb'), template_data),
          task_metadata_path => JSON.pretty_generate(task_metadata)
        }
      end

      def actual_object_name
        (object_name == module_name) ? 'init' : object_name
      end
    end
  end
end
