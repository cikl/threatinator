require 'threatinator/event'

module Threatinator
  class EventBuilder
    attr_writer :type

    def initialize(feed_provider, feed_name)
      @feed_provider = feed_provider
      @feed_name = feed_name
      self.reset
    end

    def reset
      @type = nil
      @ipv4s = []
      @fqdns = []
    end

    def build
      opts = {
        feed_provider: @feed_provider,
        feed_name: @feed_name,
        ipv4s: @ipv4s,
        fqdns: @fqdns
      }
      opts[:type] = @type unless @type.nil?
      Threatinator::Event.new(opts)
    end

    def add_fqdn(fqdn)
      @fqdns << fqdn
    end

    def add_ipv4(ipv4)
      @ipv4s << ipv4
    end
  end
end


