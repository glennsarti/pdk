require 'pdk'

module PDK
  module Validate
    class TasksValidatorGroup < ValidatorGroup
      def name
        'tasks'
      end

      def validators
        [TasksName, TasksMetadataLint].freeze
      end
    end
  end
end
