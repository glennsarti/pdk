require 'pdk'

module PDK
  module Validate
    class YAMLSyntax < Validator
      YAML_WHITELISTED_CLASSES = [Symbol].freeze

      def ignore_dotfiles
        false
      end

      def name
        'yaml-syntax'
      end

      def pattern
        [
          '**/*.yaml',
          '*.yaml',
          '**/*.yml',
          '*.yml',
        ]
      end

      def ui_job_text(_targets = [])
        _('Checking YAML syntax (%{targets}).') % {
          targets: pattern,
        }
      end

      private

      def validate_target(report, target)
        return 0 unless PDK::Util::Filesystem.file?(target)

        unless PDK::Util::Filesystem.readable?(target)
          report.add_event(
            file:     target,
            source:   name,
            state:    :failure,
            severity: 'error',
            message:  _('Could not be read.'),
          )
          return 1
        end

        begin
          ::YAML.safe_load(PDK::Util::Filesystem.read_file(target), YAML_WHITELISTED_CLASSES, [], true)

          report.add_event(
            file:     target,
            source:   name,
            state:    :passed,
            severity: 'ok',
          )
          return 0
        rescue Psych::SyntaxError => e
          report.add_event(
            file:     target,
            source:   name,
            state:    :failure,
            severity: 'error',
            line:     e.line,
            column:   e.column,
            message:  _('%{problem} %{context}') % {
              problem: e.problem,
              context: e.context,
            },
          )
          return 1
        rescue Psych::DisallowedClass => e
          report.add_event(
            file:     target,
            source:   name,
            state:    :failure,
            severity: 'error',
            message:  _('Unsupported class: %{message}') % {
              message: e.message,
            },
          )
          return 1
        end
      end
    end
  end
end
