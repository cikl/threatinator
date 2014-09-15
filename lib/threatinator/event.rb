require 'active_model'
require 'active_model/validations'
require 'virtus'

module Threatinator
  class Event
    include Virtus.model
    include ActiveModel::Validations

    VALID_TYPES = Set.new([:c2, :attacker, :malware_host, :spamming, :scanning, :phishing])

    attribute :feed_provider, String
    attribute :feed_name, String
    attribute :type, Symbol
    attribute :ipv4s, Array[String], default: lambda {|o,i| []}
    attribute :fqdns, Array[String], default: lambda {|o,i| []}

    validates :type, inclusion: {in: VALID_TYPES}

    def add_ipv4(ipv4)
      self.ipv4s << ipv4
    end

    def add_fqdn(fqdn)
      self.fqdns << fqdn
    end

    def validate!
      unless valid?
        raise Threatinator::Exceptions::InvalidAttributeError, errors.full_messages.join("\n")
      end
    end
  end
end
