require 'threatinator/output'
require 'pp'
module Threatinator
  module Plugins
    module Output
      class Rubydebug < Threatinator::FileBasedOutput
        class Config < superclass::Config
        end

        def handle_event(event)
          ::PP.pp(event, self.output_io); nil
        end
      end
    end
  end
end
