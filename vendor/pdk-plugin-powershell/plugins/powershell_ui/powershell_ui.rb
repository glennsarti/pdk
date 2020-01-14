require 'pdk'

module PDK
  module UI
    def self.stdout_mutex
      @stdout_mutex ||= Mutex.new
    end

    def self.stderr_mutex
      @stderr_mutex ||= Mutex.new
    end

    class PowershellUIJob < UIJob
      def initialize(*_)
        super
        @text_job_id = "job#{object_id}".freeze
      end

      def job_id
        @text_job_id
      end

      def stop(success, _ = nil)
        super

        text = "PDKPSUI:STOPJOB:#{job_id}:"
        text += success ? 'TRUE:' : 'FALSE:'
        text += message.to_s
        PDK::UI.stdout_mutex.synchronize do
          $stdout.puts(text)
        end
        parent_job.update unless parent_job.nil?
      end

      def start
        super
        text = "PDKPSUI:STARTJOB:#{job_id}:"
        text += (parent_job.nil? ? '' : parent_job.job_id) + ':'
        text += message.to_s
        PDK::UI.stdout_mutex.synchronize do
          $stdout.puts(text)
        end
        parent_job.update unless parent_job.nil?
      end

      def update(_message = nil)
        super
        text = "PDKPSUI:UPDATEJOB:#{job_id}:"
        complete = -1
        unless child_jobs.empty?
          completed_jobs = child_jobs.select { |job| job.completed? }
          complete = ((completed_jobs.count * 100.0) / child_jobs.count).truncate
        end
        text += "#{complete}:#{message}"

        PDK::UI.stdout_mutex.synchronize do
          $stdout.puts(text)
        end
      end
    end

    class Powershell < ::PDK::UI::BaseUI
      def initialize(*_)
        super
        $stdout.sync = true
        $stdout.binmode unless $stdout.binmode
      end

      def job_klass
        PowershellUIJob
      end

      def puts(*args)
        PDK::UI.stdout_mutex.synchronize do
          $stdout.puts args
        end
      end

      def stderr_puts(*args)
        PDK::UI.stderr_mutex.synchronize do
          $stderr.puts args
        end
      end
    end
  end
end
