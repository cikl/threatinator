require 'active_model'
require 'active_model/validations'
require 'virtus'

module Threatinator
  class Event
    include Virtus.model
    include ActiveModel::Validations

    # Extracts 'strict' checking from virtus for use as a validation mechanism.
    class VirtusStrictValidator < ActiveModel::EachValidator
      def validate_each(record, name, value)
        attribute = record.class.attribute_set[name]
        unless attribute.value_coerced?(value) || !attribute.required? && value.nil?
          record.errors.add name, 'value is not the proper type!'
        end
      end
    end

    VALID_TYPES = Set.new([:c2, :attacker, :malware_host, :spamming, :scanning, :phishing])

    attribute :feed_provider, String, coerce: false
    attribute :feed_name, String, coerce: false
    attribute :type, Symbol, coerce: false
    attribute :ipv4s, Array[String], default: lambda {|o,i| []}
    attribute :fqdns, Array[String], default: lambda {|o,i| []}

    validates :type, virtus_strict:true, inclusion: {in: VALID_TYPES}
    validates :feed_provider, virtus_strict: true
    validates :feed_name, virtus_strict: true
    validates :ipv4s, virtus_strict: true
    validates :fqdns, virtus_strict: true

    def ==(other)
      self.feed_provider == other.feed_provider &&
        self.feed_name == other.feed_name && 
        self.type == other.type &&
        self.ipv4s == other.ipv4s &&
        self.fqdns == other.fqdns
    end

    def validate!
      unless valid?
        raise Threatinator::Exceptions::InvalidAttributeError, errors.full_messages.join("\n")
      end
    end
  end
end
