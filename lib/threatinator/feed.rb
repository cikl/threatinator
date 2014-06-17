require 'virtus'

module Threatinator
  class Feed
    include Virtus.model(:strict => true)

    attribute :provider, String
    attribute :name , String
    attribute :fetcher_class, Class
    attribute :fetcher_opts, Hash, :default => lambda { |feed, attr| {} }
    attribute :parser_class, Class
    attribute :parser_opts, Hash, :default => lambda { |feed, attr| {} } 
    attribute :parser_block, Proc
  end
end
