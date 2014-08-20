module Threatinator
  class Action
    attr_reader :registry
    def initialize(registry)
      @registry = registry
    end

    def exec
      #:nocov:
      raise NotImplementedError.new
      #:nocov:
    end
  end
end
