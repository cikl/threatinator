module Threatinator
  class Parser
    # @param [Hash] opts An options hash. See subclasses for details.
    def initialize(opts = {})
    end

    # Runs the parser against the provided io, yielding records.
    # @param [IO] io The IO to be parsed.
    def run(io)
      raise NotImplementedError.new("#{self.class}#run not implemented!")
    end

    def ==(other)
      true
    end

    def eql?(other)
      self.class == other.class &&
        self == other
    end
  end
end

