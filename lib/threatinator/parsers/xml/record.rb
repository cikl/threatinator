require 'threatinator/record'

module Threatinator
  module Parsers
    module XML
      class Record < Threatinator::Record
        alias_method :node, :data
        def initialize(node, opts = {})
          super(node, opts)
        end
      end
    end
  end
end
