require 'pdk'

module PDK
  module Validate
    # A validator that runs external commands e.g. `puppet-lint`, or `puppet validate`
    # @see Validator
    class ExternalCommandValidator < Validator

      def ui_job
        # The validator has sub-commands with their own UI jobs.
        nil
      end

      def prepare_invoke!
        return if @prepared
        super

        @targets, @skipped, @invalid = parse_targets(options)

        # If invoking :per_target, split the targets array into an array of
        # single element arrays (one per target). If invoking :once, wrap the
        # targets array in another array. This is so we can loop through the
        # invokes with the same logic, regardless of which invoke style is
        # needed.
        #
        if invoke_style == :per_target
          @targets = @targets.combination(1).to_a
        else
          @targets = @targets.each_slice(1000).to_a
        end

        # If we have no targets, but we allow empty targets, create an empty target list
        # TODO: WHY IS THIS HERE? shouldn't it return 0 early on, instead of doing nothing.
        if options.fetch(:targets, []).empty? && allow_empty_targets?
          @targets = [[]]
        end

        # Register all of the commands for all of the targets
        @commands = []
        @targets.each do |invokation_targets|
          # TODO: next unless @commands[invokation_targets].nil?
          cmd_argv = parse_options(options, invokation_targets).unshift(cmd_path).compact
          cmd_argv.unshift(File.join(PDK::Util::RubyVersion.bin_path, 'ruby.exe'), '-W0') if Gem.win_platform?

          command = PDK::CLI::Exec::Command.new(*cmd_argv).tap do |c|
            c.context = :module
            c.environment = { 'PUPPET_GEM_VERSION' => options[:puppet] } if options[:puppet]
            c.ui_job = PDK.ui.register_job(ui_job_text(invokation_targets), options[:parent_ui_job])
          end

          @commands << { command: command, invokation_targets: invokation_targets }
        end
        nil
      end

      def invoke(report)
        require 'pdk/cli/exec/command'

        prepare_invoke!

        process_skipped(report, @skipped)
        process_invalid(report, @invalid)

        return 0 if @targets.empty?

        PDK::Util::Bundler.ensure_binstubs!(cmd)

        require 'pdk/cli/exec_group'
        exec_group = PDK::CLI::ExecGroup.create(ui_job_text(@targets), { parallel: false }, options)

        # Register all of the commands for all of the targets
        @commands.each do |item|
          command = item[:command]
          invokation_targets = item[:invokation_targets]

          exec_group.register do
            result = command.execute!

            begin
              parse_output(report, result, invokation_targets.compact)
            rescue PDK::Validate::ParseOutputError => e
              PDK.ui.stderr_puts(e.message)
            end
            result[:exit_code]
          end
        end

        # Now execute and get the return code
        exec_group.exit_code
      end
    end
  end
end
