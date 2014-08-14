require 'threatinator/output'
require 'pp'
module Threatinator
  module Plugins
    module Output
      class Rubydebug < Threatinator::FileBasedOutput
        def handle_event(event)
          ::PP.pp(event, self.output_io); nil
        end
      end
    end
  end
end
