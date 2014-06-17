require 'threatinator/parser'
require 'threatinator/fetcher'

module FeedSpec
  class Fetcher < Threatinator::Fetcher
    def initialize(opts = {})
      @io = opts[:io]
    end
    def fetch; @io; end
  end
  class Parser < Threatinator::Parser
  end
end
