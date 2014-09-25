require 'threatinator/config/base'
require 'threatinator/logger'

module Threatinator
  module Config
    class Logger < Threatinator::Config::Base
      attribute :level, String, default: Threatinator::Logger.level_string, 
        coercer: lambda { |v| v.to_s.upcase },
        description: "Set the logging level: #{::Threatinator::Logger.levels.join(',')}"
    end
  end
end


