require 'pdk'

module PDK
  module Validate
    class Validator
      # Controls how many times the validator is invoked.
      #
      #   :once -       The validator will be invoked once and passed all the
      #                 targets.
      #   :per_target - The validator will be invoked for each target
      #                 separately.
      # @abstract
      def invoke_style
        :once
      end

      attr_reader :options

      # @option :parent_ui_job [PDK::UI::UIJob] The parent UI job for this invocation
      def initialize(options = {})
        @options = options.dup.freeze
        @prepared = false
      end

      def ui_job
        return @ui_job unless @ui_job.nil?
        # TODO: Could be a one-liner
        @ui_job = PDK.ui.register_job(ui_job_text, options[:parent_ui_job])
      end

      def prepare_invoke!
        return if @prepared
        @prepared = true
        # Register the UI job
        ui_job
      end

      def cmd_path
        File.join(PDK::Util.module_root, 'bin', cmd)
      end

      # Parses the target strings provided from the CLI
      #
      # @param options [Hash] A Hash containing the input options from the CLI.
      #
      # @return targets [Array] An Array of Strings containing target file paths
      #                         for the validator to validate.
      # @return skipped [Array] An Array of Strings containing targets
      #                         that are skipped due to target not containing
      #                         any files that can be validated by the validator.
      # @return invalid [Array] An Array of Strings containing targets that do
      #                         not exist, and will not be run by validator.
      def parse_targets(options)
        # If no targets are specified, then we will run validations from the
        # base module directory.
        targets = options.fetch(:targets, []).empty? ? [PDK::Util.module_root] : options[:targets]

        targets.map! { |r| r.gsub(File::ALT_SEPARATOR, File::SEPARATOR) } if File::ALT_SEPARATOR
        skipped = []
        invalid = []
        matched = targets.map { |target|
          if respond_to?(:pattern)
            if PDK::Util::Filesystem.directory?(target)
              target_root = PDK::Util.module_root
              pattern_glob = Array(pattern).map { |p| PDK::Util::Filesystem.glob(File.join(target_root, p), File::FNM_DOTMATCH) }
              target_list = pattern_glob.flatten
                                        .select { |glob| PDK::Util::Filesystem.fnmatch(File.join(PDK::Util::Filesystem.expand_path(PDK::Util.canonical_path(target)), '*'), glob, File::FNM_DOTMATCH) }
                                        .map { |glob| Pathname.new(glob).relative_path_from(Pathname.new(PDK::Util.module_root)).to_s }

              ignore_list = ignore_pathspec
              target_list = target_list.reject { |file| ignore_list.match(file) }

              skipped << target if target_list.flatten.empty?
              target_list
            elsif PDK::Util::Filesystem.file?(target)
              if Array(pattern).include? target
                target
              elsif Array(pattern).any? { |p| PDK::Util::Filesystem.fnmatch(PDK::Util::Filesystem.expand_path(p), PDK::Util::Filesystem.expand_path(target), File::FNM_DOTMATCH) }
                target
              else
                skipped << target
                next
              end
            else
              invalid << target
              next
            end
          else
            target
          end
        }.compact.flatten
        [matched, skipped, invalid]
      end

      def ignore_pathspec
        require 'pdk/module'

        ignore_pathspec = PDK::Module.default_ignored_pathspec(ignore_dotfiles?)

        if respond_to?(:pattern_ignore)
          Array(pattern_ignore).each do |pattern|
            ignore_pathspec.add(pattern)
          end
        end

        ignore_pathspec
      end

      # @abstract
      def ignore_dotfiles?
        true
      end

      def parse_options(_options, targets)
        targets
      end

      def ui_job_text(_targets = nil)
        _('Invoking %{cmd}') % { cmd: cmd }
      end

      def process_skipped(report, skipped = [])
        skipped.each do |skipped_target|
          PDK.logger.debug(_('%{validator}: Skipped \'%{target}\'. Target does not contain any files to validate (%{pattern}).') % { validator: name, target: skipped_target, pattern: pattern })
          report.add_event(
            file:     skipped_target,
            source:   name,
            message:  _('Target does not contain any files to validate (%{pattern}).') % { pattern: pattern },
            severity: :info,
            state:    :skipped,
          )
        end
      end

      def process_invalid(report, invalid = [])
        invalid.each do |invalid_target|
          PDK.logger.debug(_('%{validator}: Skipped \'%{target}\'. Target file not found.') % { validator: name, target: invalid_target })
          report.add_event(
            file:     invalid_target,
            source:   name,
            message:  _('File does not exist.'),
            severity: :error,
            state:    :error,
          )
        end
      end

      # Controls how the validator behaves if not passed any targets.
      #
      #   true  - PDK will not pass the globbed targets to the validator command
      #           and it will instead rely on the underlying tool to find its
      #           own default targets.
      #   false - PDK will pass the globbed targets to the validator command.
      # @abstract
      def allow_empty_targets?
        false
      end

      # @abstract
      def invoke(report)
        prepare_invoke!
        0
      end
    end
  end
end
