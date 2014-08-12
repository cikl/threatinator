require 'threatinator/output'
require 'threatinator/plugins'
module Threatinator
  module Outputs
    class Null < Threatinator::Output
      def handle_event(event)
      end

      def finish
      end

      Threatinator::Plugins.register_output(:null, self)
    end
  end
end

