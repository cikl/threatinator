require 'threatinator/output'
require 'pp'
module Threatinator
  module Outputs
    class Rubydebug < Threatinator::Output
      def initialize(feed, output_io)
        super(feed, output_io)
      end

      def handle_event(event)
        ::PP.pp(event, self.output_io); nil
      end
    end
  end
end

