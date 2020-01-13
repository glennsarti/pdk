# require 'logger'
# require 'pdk'

module PDK
  module Logger
    class PowerShell < ::Logger
      WRAP_COLUMN_LIMIT = 78

      def initialize
        super($stdout)
        # Flush msgs immediately
        $stdout.sync = true

        @sent_messages = {}

        self.formatter = proc do |severity, _datetime, _progname, msg|
          msg_text = msg.is_a?(Hash) ? msg[:text] : msg
          "PDKPSLOGGER:#{severity}:#{msg_text.length}:#{msg_text}\n"
        end

        self.level = ::Logger::INFO
      end

      def warn_once(*args)
        hash = args.inspect.hash
        return if (@sent_messages[::Logger::WARN] ||= {}).key?(hash)
        @sent_messages[::Logger::WARN][hash] = true
        warn(*args)
      end

      def enable_debug_output
        self.level = ::Logger::DEBUG
      end

      def debug?
        level == ::Logger::DEBUG
      end
    end
  end
end
