require 'threatinator/event'
require 'threatinator/exceptions'
require 'threatinator/model/observables/ipv4'
require 'ip'

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
      @urls = []
    end

    def build
      opts = {
        feed_provider: @feed_provider,
        feed_name: @feed_name,
      }
      opts[:type] = @type unless @type.nil?

      ret = Threatinator::Event.new(opts)

      @ipv4s.each do |ipv4, opts|
        opts = opts.dup
        if ipv4.is_a?(::String)
          ipv4 = ::IP::V4.parse(ipv4)
        end
        opts[:ipv4] = ipv4
        ret.ipv4s << Threatinator::Model::Observables::Ipv4.new(opts)
      end
      @fqdns.each do |fqdn|
        ret.fqdns << fqdn
      end
      @urls.each do |url|
        url = begin
          ::Addressable::URI.parse(url)
        rescue TypeError => e
          raise Threatinator::Exceptions::EventBuildError, "Failed to parse URL"
        end
        ret.urls << url
      end
      ret
    rescue Threatinator::Exceptions::InvalidAttributeError => e
      raise Threatinator::Exceptions::EventBuildError, e.message
    end

    def add_fqdn(fqdn)
      @fqdns << fqdn
    end

    def add_ipv4(ipv4, opts = {})
      @ipv4s << [ipv4, opts]
    end

    def add_url(url)
      @urls << url
    end
  end
end


