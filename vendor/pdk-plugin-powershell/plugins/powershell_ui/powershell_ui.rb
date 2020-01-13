require 'pdk'

module PDK
  module UI
    class PowershellUIJob < UIJob
      #@@text_job_id = 1

      def initialize(*_)
        super
        # TODO: This is horrible
        # @this_job_id = "%03d" % @@text_job_id
        # @@text_job_id += 1
      end

      # def depth
      #   parent_job.nil? ? 0 : parent_job.depth + 1
      # end

      def stop(success, _ = nil)
        super
        # text = "(#{@this_job_id}) " + ("  " * depth) + message
        # if success
        #   text += " completed with success"
        # else
        #   text += " completed with an error"
        # end
        # PDK.ui.puts(text)
        text = "PDKPSUI:STOPJOB:#{object_id}:"
        text += success ? 'TRUE' : 'FALSE'
        $stdout.puts(text)
      end

      def start
       super
       text = "PDKPSUI:STARTJOB:#{object_id}:#{message}"
       $stdout.puts(text)
      end
    end

    class Powershell < ::PDK::UI::BaseUI
      def initialize(*_)
        super
        @stdout_mutex = Mutex.new
        @stderr_mutex = Mutex.new
      end

      def job_klass
        PowershellUIJob
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
          #$stderr.write "\e[35m"
          $stderr.puts args
          #$stderr.write "\e[0m"
        end
      end

      # def job_default_options
      #   return @job_default_options.dup unless @job_default_options.nil?
      #   @job_default_options = {}
      #   return @job_default_options.dup unless Gem.win_platform?
      #   # Windows Terminal and VSCode both support pretty emojis and extended characters
      #   return @job_default_options.dup if ENV['WT_SESSION'] || ENV['TERM_PROGRAM'] == 'vscode'
      #   @job_default_options = { success_mark: '*', error_mark: 'X' }
      #   @job_default_options.dup
      # end
    end
  end
end
