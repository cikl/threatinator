require 'threatinator/logger'

module Threatinator
  # Mixin for mixing logging facilities into classes. 
  module Logging
    def self.included(base)
      base.extend(LoggingClassMethods)
    end

    def logger
      @logger ||= self.class.logger
    end
  end

  module LoggingClassMethods
    def logger
      @logger ||= Threatinator::Logger.logger_for(self.name)
    end
  end
end
