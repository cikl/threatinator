module Threatinator
  class Parser

    # @param [Hash] opts An options hash. See subclasses for details.
    def initialize(opts = {})
    end

    # What is emitted by this method will vary by the parser implementation.
    def each
      raise NotImplementedError.new("#{self.class}#each not implemented!")
    end
  end
end

