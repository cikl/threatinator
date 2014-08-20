require 'threatinator/output'
module Threatinator
  module Plugins
    module Output
      class Null < Threatinator::Output
        class Config < superclass::Config
        end

        def handle_event(event)
        end

        def finish
        end
      end
    end
  end
end
