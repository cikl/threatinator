require 'threatinator/filter'

module Threatinator
  module Filters
    # Basic filter that allows for arbitrary filtering.
    class Block < Threatinator::Filter
      def initialize(block)
        @block = block
      end

      # @return [Boolean] true if filtered, false otherwise.
      def filter?(*args)
        !! @block.call(*args)
      end
    end
  end
end
