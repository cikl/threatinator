require 'threatinator/cli/parser'
require 'threatinator/config/logger'
require 'threatinator/logger'
module Threatinator
  module CLI
    def self.process!(args)
      parser = Parser.new
      ret = parser.parse(args)
      builder = parser.builder
      return ret if builder.nil?

      conf = Threatinator::Config::Logger.new(parser.config_hash['logger'])
      Threatinator::Logger.configure_logger(conf)

      builder.build.exec
      ret
    end
  end
end
