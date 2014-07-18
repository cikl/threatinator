module Threatinator
  # Decodes/Extracts data from an input IO, producing a new IO. The decoder is
  # initialized with a configuration, and then #decode is called upon an IO
  # object.
  class Decoder
    attr_reader :encoding

    # @param [Hash] opts An options hash
    # @option opts [String] :encoding The encoding for the output IO. Defaults
    #  to "utf-8"
    def initialize(opts = {})
      @encoding = opts[:encoding] || "utf-8"
    end

    # Decodes an input IO, returning a brand new IO.
    # @param [IO] io The IO to decode
    # @return [IO] A new IO.
    def decode(io)
      #:nocov:
      raise NotImplementedError.new("#{self.class}#decode not implemented!")
      #:nocov:
    end
  end
end
