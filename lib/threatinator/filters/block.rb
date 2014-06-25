require 'threatinator/filter'

module Threatinator
  module Filters
    # Basic filter that allows for arbitrary filtering.
    class Block < Threatinator::Filter
      def initialize(block)
        @block = block
      end

      # @param [Threatinator::Record] record The record to filter
      # @return [Boolean] true if filtered, false otherwise.
      def filter?(record)
        !! @block.call(record)
      end
    end
  end
end
