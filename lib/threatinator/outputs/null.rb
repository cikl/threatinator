require 'threatinator/output'
module Threatinator
  module Outputs
    class Null < Threatinator::Output
      def initialize(feed, output_io)
        super(feed, output_io)
      end

      def handle_event(event)
      end
    end
  end
end

