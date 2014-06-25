require 'threatinator/filter'

module Threatinator
  module Filters
    # Filters out any lines of text that begin with a comment '#'
    class Comments < Threatinator::Filter
      # @param [Threatinator::Record] record The record to filter
      # @return [Boolean] true if filtered, false otherwise.
      def filter?(record)
        record.data[0] == '#'
      end
    end
  end
end


