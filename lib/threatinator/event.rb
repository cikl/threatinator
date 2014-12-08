require 'threatinator/model/base'
require 'threatinator/model/observables/ipv4_collection'
require 'threatinator/model/observables/fqdn_collection'
require 'threatinator/model/observables/url_collection'
require 'equalizer'
require 'set'

module Threatinator
  class Event < Threatinator::Model::Base
    include Equalizer.new(:feed_provider, :feed_name, :type, :ipv4s, :fqdns, :urls)
    attr_reader :feed_provider, :feed_name, :type, :ipv4s, :fqdns, :urls

    VALID_TYPES = Set.new([:c2, :attacker, :malware_host, :spamming, :scanning, :phishing])

    validates :feed_provider, :feed_name, type: ::String
    validates :type, type: ::Symbol, allow_nil: false, inclusion: {in: VALID_TYPES}
    validates :ipv4s, type: Threatinator::Model::Observables::Ipv4Collection
    validates :fqdns, type: Threatinator::Model::Observables::FqdnCollection
    validates :urls, type: Threatinator::Model::Observables::UrlCollection

    # @param [Hash] opts
    # @option opts [String] :feed_provider The name of the feed provider
    # @option opts [String] :feed_name The name of the feed
    # @option opts [Symbol] :type The 'type' of feed.
    # @option opts [#each] :ipv4s A collection of ipv4s
    # @option opts [#each] :fqdns A collection of FQDNs
    # @option opts [#each] :urls A collection of Urls
    def initialize(opts = {})
      @feed_provider = opts[:feed_provider]
      @feed_name = opts[:feed_name]
      @type = opts[:type]
      @ipv4s = Threatinator::Model::Observables::Ipv4Collection.new(opts[:ipv4s] || [])
      @fqdns = Threatinator::Model::Observables::FqdnCollection.new(opts[:fqdns] || [])
      @urls = Threatinator::Model::Observables::UrlCollection.new(opts[:urls] || [])
      super()
    end
  end
end
