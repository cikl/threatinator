module Threatinator
  class Parser
    attr_reader :io
    protected :io

    # @param [IO-like object] io An IO-like object
    # @param [Hash] opts An options hash. See subclasses for details.
    def initialize(io, opts = {})
      @io = io
    end

    # What is emitted by this method will vary by the parser implementation.
    def each
      raise NotImplementedError.new("#{self.class}#each not implemented!")
    end
  end
end

