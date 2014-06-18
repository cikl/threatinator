require 'threatinator/filter'

module Threatinator
  module Filters
    # Filters on any lines of text that consist entirely of whitespace
    class Whitespace < Threatinator::Filter
      def initialize()
        @re = /^\s*$/
      end

      # @return [Boolean] true if filtered, false otherwise.
      def filter?(line)
        !! @re.match(line)
      end
    end
  end
end

