require 'pdk'

module PDK
  module Validate
    class ValidatorGroup
      attr_reader :options

      # @param validators [ValidatorGroup, Validator]
      # @option :parent_ui_job [PDK::UI::UIJob] The parent UI job for this invocation
      def initialize(options = {})
        @options = options.dup.freeze
        @ui_job = nil
        @prepared = false
      end

      def ui_job_text(_targets = nil)
        _('Running %{name} validators ...') % { name: name }
      end

      def prepare_invoke!
        #return if @prepared
        @prepared = true
        # Force our UI Job to be registered
        ui_job
        # Prepare child validators
        validator_instances.each { |instance| instance.prepare_invoke! }
        @prepared = true
        nil
      end

      def ui_job
        return @ui_job unless @ui_job.nil?
        # TODO: Could be a one-liner
        @ui_job = PDK.ui.register_job(ui_job_text, options[:parent_ui_job])
      end

      # @abstract
      def name; end

      # @abstract
      def validators; end

      # @param report See PDK::Validate::Validator.invoke
      def invoke(report)
        exit_code = 0

        prepare_invoke!
        ui_job.start

        validator_instances.each do |instance|
          exit_code = instance.invoke(report)
          break if exit_code != 0
        end

        ui_job.stop(exit_code.zero?)

        exit_code
      end

      def validator_instances
        @validator_instances ||= validators.map { |klass| klass.new(options.merge(parent_ui_job: ui_job)) }
      end
    end
  end
end
