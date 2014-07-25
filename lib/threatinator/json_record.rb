require 'threatinator/record'

module Threatinator
  class JSONRecord < Record
    attr_reader :key
    def initialize(object, opts = {})
      @key = opts.delete(:key)
      super(object, opts)
    end

    def ==(other)
      @key == other.key &&
        super(other)
    end
  end
end
