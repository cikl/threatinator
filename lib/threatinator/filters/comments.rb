require 'threatinator/filter'

module Threatinator
  module Filters
    # Filters out any lines of text that begin with a comment '#'
    class Comments < Threatinator::Filter
      # @return [Boolean] true if filtered, false otherwise.
      def filter?(line)
        line[0] == '#'
      end
    end
  end
end


