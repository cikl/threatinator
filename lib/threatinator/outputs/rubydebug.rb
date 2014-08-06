require 'threatinator/output'
require 'threatinator/plugins'
require 'pp'
module Threatinator
  module Outputs
    class Rubydebug < Threatinator::FileBasedOutput
      def handle_event(event)
        ::PP.pp(event, self.output_io); nil
      end

      Threatinator::Plugins.register_output(:rubydebug, self)
    end
  end
end

