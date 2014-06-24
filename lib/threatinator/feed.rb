require 'threatinator/property_definer'

module Threatinator
  class Feed
    include Threatinator::PropertyDefiner

    def initialize(opts = {})
      _parse_properties(opts)
    end

    property :provider, type: String
    property :name, type: String
    property :fetcher_class, type: Class
    property :fetcher_opts, type: Hash, default: lambda { Hash.new }
    property :parser_class, type: Class
    property :parser_opts, type: Hash, default: lambda { Hash.new }
    property :parser_block, type: Proc
    property :filters, type: Array, default: lambda { Array.new }
  end
end
