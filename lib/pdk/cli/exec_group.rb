require 'pdk'

module PDK
  module CLI
    class ExecGroup
      def self.create(message, create_options = {}, group_opts = {})
        if create_options[:parallel]
          ParallelExecGroup.new(message, group_opts)
        else
          SerialExecGroup.new(message, group_opts)
        end
      end

      def initialize(_message, opts = {})
        @options = opts
      end

      def register(&block)
        raise PDK::CLI::FatalError, _('No block registered') unless block_given?
      end

      def exit_code; end
    end

    class SerialExecGroup < ExecGroup
      def initialize(message, opts = {})
        super(message, opts)
        @procs = []
      end

      def register(&block)
        super(&block)

        @procs << block
      end

      def exit_code
        exit_codes = @procs.map(&:call)
        exit_codes.nil? ? 0 : exit_codes.max
      end
    end

    class ParallelExecGroup < ExecGroup
      def initialize(message, opts = {})
        super(message, opts)
        @threads = []
        @exit_codes = []
      end

      def register(&block)
        super(&block)

        @threads << Thread.new do
                               GettextSetup.initialize(File.absolute_path('../../../locales', File.dirname(__FILE__)))
                               GettextSetup.negotiate_locale!(GettextSetup.candidate_locales)
                               @exit_codes << yield
                             end
      end

      def exit_code
        @threads.each(&:join)
        return 0 if @exit_codes.empty?
        @exit_codes.max
      end
    end
  end
end
