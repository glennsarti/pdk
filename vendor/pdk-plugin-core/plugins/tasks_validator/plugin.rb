require 'pdk'

# Setup the autoloaders. Not the greatest, but meh!
module PDK
  module Validate
    autoload :TasksName, File.expand_path(File.join(__dir__, 'tasks_name'))
    autoload :TasksMetadataLint, File.expand_path(File.join(__dir__, 'tasks_metadata_lint'))
    autoload :TasksValidatorGroup, File.expand_path(File.join(__dir__, 'tasks_validator_group'))
  end
end

module PDKCorePlugins
  class TasksValidatorPlugin < PDK::PluginTypes::Validator
    def initialize
      super('tasks_validator')
    end

    def validator_klass
      PDK::Validate::TasksValidatorGroup
    end
  end
end

PDK::PluginManager.instance.register(PDKCorePlugins::TasksValidatorPlugin.new)
