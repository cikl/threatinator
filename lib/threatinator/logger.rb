require 'log4r'

module Threatinator
  module Logger
    # The log levels don't get defined until the first time a logger is 
    # initialized. So, we call the root logger once just to get this to happen.
    Log4r::RootLogger.instance

    def self.logger_for(name)
      ::Log4r::Logger[name] || ::Log4r::Logger.new(name)
    end

    def self.default_logger
      return @logger unless @logger.nil?

      @logger = logger_for('Threatinator')
      formatter = ::Log4r::PatternFormatter.new(:pattern => '[%d] %l %C: %M')

      console_outputter = ::Log4r::StderrOutputter.new('console', formatter: formatter)
      @logger.add console_outputter

      @logger.level = ::Log4r::INFO
      @logger
    end

    # @param [Threatinator::Config::Logger] config Logging configuration object
    def self.configure_logger(config)
      if config.level
        if l = self.levels.index(config.level)
          default_logger.level = l
        else
          default_logger.warn("Ignoring unknown logging level: #{config.level.inspect}.")
        end
      end
    end

    def self.level
      default_logger.level
    end

    def self.level=(l)
      default_logger.level = l
    end

    def self.level_string
      levels[level]
    end

    def self.levels
      default_logger.levels
    end

    # Initializes the default logger. This allows us to pull the logger levels.
    self.default_logger()

    module Levels
      ALL   = ::Log4r::ALL
      DEBUG = ::Log4r::DEBUG
      INFO  = ::Log4r::INFO
      WARN  = ::Log4r::WARN
      ERROR = ::Log4r::ERROR
      FATAL = ::Log4r::FATAL
      OFF   = ::Log4r::OFF
    end
  end
end
