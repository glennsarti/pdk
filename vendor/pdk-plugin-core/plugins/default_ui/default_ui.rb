require 'pdk'

module PDK
  module UI
    class SpinnerUIJob < UIJob
      attr_accessor :spinner

      def initialize(ui, message, parent_job = nil, options = {})
        super
        if parent_job.nil?
          @spinner = TTY::Spinner::Multi.new("[:spinner] #{message}", options)
        else
          @spinner = parent_job.spinner.register("[:spinner] #{message}", options)
        end
      end

      def stop(success, message = nil)
        super(success, message)
        if success
          @spinner.success
        else
          @spinner.error
        end
      end

      def start
       super
       @spinner.auto_spin
      end
    end

    class TextUIJob < UIJob
      attr_accessor :spinner

      @@text_job_id = 1

      def initialize(*_)
        super
        # TODO: This is horrible
        @this_job_id = "%03d" % @@text_job_id
        @@text_job_id += 1
      end

      def depth
        parent_job.nil? ? 0 : parent_job.depth + 1
      end

      def stop(success, _ = nil)
        super
        text = "(#{@this_job_id}) " + ("  " * depth) + message
        if success
          text += " completed with success"
        else
          text += " completed with an error"
        end
        PDK.ui.puts(text)
      end

      def start
       super
       text = "(#{@this_job_id}) " + ("  " * depth) + message
       PDK.ui.puts(text)
      end
    end

    # Default UI
    # STDIN/STDERR with spinners etc.
    class Default < ::PDK::UI::BaseUI
      def initialize(*_)
        super
        @stdout_mutex = Mutex.new
        @stderr_mutex = Mutex.new

        @job_type = PDK::CLI::Util.interactive? ? SpinnerUIJob : TextUIJob
      end

      def job_klass
        @job_type
      end

      def puts(*args)
        # BRIGHT YELLOW PLEASE? Maybe?
        @stdout_mutex.synchronize do
          #$stdout.write "\e[33m"
          #$stdout.write "\e[0m"
          $stdout.puts args
          #$stdout.write "\e[0m"
        end
      end

      def stderr_puts(*args)
        # BRIGHT RED PLEASE
        @stderr_mutex.synchronize do
          $stderr.write "\e[35m"
          $stderr.puts args
          $stderr.write "\e[0m"
        end
      end

      def job_default_options
        return @job_default_options.dup unless @job_default_options.nil?
        @job_default_options = {}
        return @job_default_options.dup unless Gem.win_platform?
        # Windows Terminal and VSCode both support pretty emojis and extended characters
        return @job_default_options.dup if ENV['WT_SESSION'] || ENV['TERM_PROGRAM'] == 'vscode'
        @job_default_options = { success_mark: '*', error_mark: 'X' }
        @job_default_options.dup
      end
    end
  end
end

# Assume everything has color support
# https://github.com/ddfreyne/cri/issues/106
if Gem.win_platform? && !defined?(::Win32::Console::ANSI)
  module Win32
    module Console
      module ANSI
      end
    end
  end
end

require 'tty-spinner'

# Replace the built-in tty check in tty-spinner with our own implementation
# that allows us to mock the behaviour during acceptance tests.
module TTY
  class Spinner
    def tty?
      require 'pdk/cli/util'

      PDK::CLI::Util.interactive?
    end
  end
end
