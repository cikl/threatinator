require 'threatinator/property_definer'

module Threatinator
  class Event
    include Threatinator::PropertyDefiner

    VALID_TYPES = Set.new([:c2, :attacker, :malware_host, :spamming, :scanning, :phishing])

    def initialize(opts = {})
      _parse_properties(opts)
    end

    property :type, type: Symbol, validate: lambda { |obj, val| VALID_TYPES.include?(val) }
    property :ipv4s, type: Array, default: lambda { Array.new }
    property :fqdns, type: Array, default: lambda { Array.new }

    def add_ipv4(ipv4)
      self.ipv4s << ipv4
    end

    def add_fqdn(fqdn)
      self.fqdns << fqdn
    end
  end
end
