require 'threatinator/cli/parser'
module Threatinator
  module CLI
    def self.process!(args)
      parser = Parser.new
      ret = parser.parse(args)
      if builder = parser.builder
        builder.build.exec
      end
      ret
    end
  end
end
