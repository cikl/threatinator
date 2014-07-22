module Threatinator
  class Fetcher

    # @param [Hash] opts An options hash. See subclasses for details.
    def initialize(opts = {})
    end

    # @return [IO] an IO object
    def fetch
      raise NotImplementedError.new("#{self.class}#fetch not implemented!")
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
