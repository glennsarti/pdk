require 'pdk'

module PDK
  module Validate
    # A validator that runs ruby code internal to the PDK e.g. JSON and YAML validation, for a single file
    # @see Validator
    class InternalRubyValidator < Validator
      def ui_job
        @ui_job
      end

      def prepare_invoke!
        return if @prepared
        super

        @targets, @skipped, @invalid = parse_targets(options)
        @ui_job = PDK.ui.register_job(ui_job_text(@targets), options[:parent_ui_job])

        nil
      end

      def invoke(report)
        prepare_invoke!

        process_skipped(report, @skipped)
        process_invalid(report, @invalid)

        return 0 if @targets.empty?

        return_val = 0

        before_validation

        ui_job.start
        @targets.each do |target|
          validation_result = validate_target(report, target)
          if validation_result.nil?
            report.add_event(
              file:     target,
              source:   name,
              state:    :failure,
              severity: 'error',
              message:  "Validation did not return an exit code for #{target}",
            )
            validation_result = 1
          end
          return_val = validation_result if return_val.zero?
        end

        ui_job.stop(return_val.zero?)
        return_val
      end

      private

      # @abstract
      def validate_target(report, target); end

      # @abstract
      def before_validation; end
    end
  end
end
