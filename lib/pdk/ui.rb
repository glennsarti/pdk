module PDK
  module UI
    class BaseUI
      def initialize(*_)
        @ui_jobs = []
      end

      def puts(*_); end

      def stderr_puts(*_); end

      def job_klass
        UIJob
      end

      def register_job(message, parent_job = nil)
        # TODO: Should be wrapped in a mutex??
        new_job = job_klass.new(self, message, parent_job, job_default_options)
        @ui_jobs << new_job
        parent_job.add_child_job(new_job) unless parent_job.nil?
        new_job
      end

      def job_default_options
        {}
      end
    end

    class UIJob
      #attr_reader :id

      attr_accessor :message

      # UI plugin specific options
      attr_accessor :options

      attr_reader :child_jobs

      attr_accessor :parent_job

      def initialize(ui, message, parent_job = nil, options = {})
        @ui = ui
        @message = message
        @parent_job = parent_job
        @child_jobs = []
        @options = options
      end

      def stop(_success, _message = nil); end

      def start; end

      def update(_message = nil); end

      # @api private
      def add_child_job(job)
        # TODO: Should be wrapped in a mutex??
        @child_jobs << job
      end
    end
  end
end
