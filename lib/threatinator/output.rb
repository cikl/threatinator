require 'threatinator/config/base'

module Threatinator
  class Output
    def initialize(config)
    end

    def handle_event(event)
      #:nocov:
      raise NotImplementedError.new("#{self.class}#handle_event is not implemented")
      #:nocov:
    end

    def finish
      #:nocov:
      raise NotImplementedError.new("#{self.class}#finish is not implemented")
      #:nocov:
    end

    class Config < Threatinator::Config::Base
    end
  end

  class FileBasedOutput < Output
    attr_reader :output_io
    protected :output_io

    def initialize(config)
      super(config)
      if io = config.io
        @output_io = io
      elsif filename = config.filename
        @output_io = File.open(filename, 'w:UTF-8')
      else
        @output_io = $stdout.dup
      end
    end

    def finish
      @output_io.close
    end

    class Config < superclass::Config
      attribute :filename, String, 
        description: "Path to the file where output will be written"

      attribute :io
    end
  end
end
