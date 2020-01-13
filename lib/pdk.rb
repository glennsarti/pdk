require 'pdk/i18n'

module PDK
  autoload :Analytics, 'pdk/analytics'
  autoload :AnswerFile, 'pdk/answer_file'
  autoload :Build, 'pdk/build'
  autoload :Config, 'pdk/config'
  autoload :Generate, 'pdk/generate'
  #autoload :Logger, 'pdk/logger'
  autoload :FileUpdateManager, 'pdk/file_update_manager'
  autoload :Module, 'pdk/module'
  autoload :Report, 'pdk/report'
  autoload :TemplateFile, 'pdk/template_file'
  autoload :TEMPLATE_REF, 'pdk/version'
  autoload :Util, 'pdk/util'
  autoload :Validate, 'pdk/validate'
  autoload :VERSION, 'pdk/version'

  # TODO: Refactor backend code to not raise CLI errors or use CLI util
  #       methods.
  module CLI
    autoload :ExitWithError, 'pdk/cli/errors'
    autoload :FatalError, 'pdk/cli/errors'
    autoload :Util, 'pdk/cli/util'
    autoload :Exec, 'pdk/cli/exec'
    autoload :ExecGroup, 'pdk/cli/exec_group'
  end

  module Test
    autoload :Unit, 'pdk/tests/unit'
  end

  module Logger; end

  module UI; end
  require 'pdk/ui'
  #autoload :UI, 'pdk/ui'

  # Singleton accessor to the current answer file being used by the PDK.
  #
  # @return [PDK::AnswerFile] The AnswerFile instance currently being used by
  #   the PDK.
  def self.answers
    @answer_file ||= PDK::AnswerFile.new
  end

  # Specify the path to a custom answer file that the PDK should use.
  #
  # @param path [String] A path on disk to the file where the PDK should store
  #   answers to interactive questions.
  def self.answer_file=(path)
    @answer_file = PDK::AnswerFile.new(path)
  end

  def self.config
    @config ||= PDK::Config.new
  end

  def self.analytics
    @analytics ||= PDK::Analytics.build_client(
      logger:        PDK.logger,
      disabled:      PDK::Util::Env['PDK_DISABLE_ANALYTICS'] || PDK.config.user['analytics']['disabled'],
      user_id:       PDK.config.user['analytics']['user-id'],
      app_id:        "UA-139917834-#{PDK::Util.development_mode? ? '2' : '1'}",
      client:        :google_analytics,
      app_name:      'pdk',
      app_version:   PDK::VERSION,
      app_installer: PDK::Util.package_install? ? 'package' : 'gem',
    )
  end

  # Should be last-ish
  require 'pdk/plugin_manager'
  PDK::PluginManager.instance.find_all_plugins

  # These NEED the plugins to be loaded first
  # So it HAS to be after `PDK::PluginManager.instance.find_all_plugins`
  def self.ui
    return @ui unless @ui.nil?

    plugin_name = plugin_name_from_env('PDK_UI_PLUGIN', 'default_ui')
    PDK::PluginManager.instance.activate_plugins!([plugin_name])
    plugin = PDK::PluginManager.instance[plugin_name]

    @ui = plugin.ui_klass.new
  end

  def self.logger
    return @logger unless @logger.nil?

    plugin_name = plugin_name_from_env('PDK_LOGGER_PLUGIN', 'default_logger')
    PDK::PluginManager.instance.activate_plugins!([plugin_name])
    plugin = PDK::PluginManager.instance[plugin_name]

    @logger = plugin.logger_klass.new
  end

  # TODO: private.  Perhaps PDK::Logger module is better for this?
  def self.plugin_name_from_env(env_var, default)
    var_val = ENV[env_var]
    return default if var_val.nil?
    return default if PDK::PluginManager.instance.plugin_metadata(var_val).nil?
    var_val
  end
end
