require 'threatinator/filter'

module Threatinator
  module Filters
    # Filters on any lines of text that consist entirely of whitespace
    class Whitespace < Threatinator::Filter
      def initialize()
        @re = /^\s*$/
      end

      # @param [Threatinator::Record] record The record to filter
      # @return [Boolean] true if filtered, false otherwise.
      def filter?(record)
        !! @re.match(record.data)
      end
    end
  end
end

