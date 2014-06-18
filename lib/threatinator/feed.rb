require 'virtus'
require 'threatinator/filter'

module Threatinator
  class Feed
    def initialize(opts = {})
      self.provider = opts.delete(:provider) if opts.has_key?(:provider)
      self.name = opts.delete(:name) if opts.has_key?(:name)
      self.fetcher_class = opts.delete(:fetcher_class) if opts.has_key?(:fetcher_class)
      self.fetcher_opts = opts.delete(:fetcher_opts) || {}
      self.parser_class = opts.delete(:parser_class) if opts.has_key?(:parser_class)
      self.parser_opts = opts.delete(:parser_opts) || {}
      self.parser_block = opts.delete(:parser_block) if opts.has_key?(:parser_block)
      self.filters = opts.delete(:filters) || []
    end

    def self.property(name, klass)
      ivar = "@#{name}".to_sym
      define_method("#{name}=".to_sym) do |newval|
        unless newval.kind_of?(klass)
          raise Threatinator::Exceptions::InvalidAttributeError.new(name, klass, newval)
        end
        instance_variable_set(ivar, newval)
      end
      define_method(name) do 
        instance_variable_get(ivar)
      end
    end

    property :provider, String
    property :name, String
    property :fetcher_class, Class
    property :fetcher_opts, Hash
    property :parser_class, Class
    property :parser_opts, Hash
    property :parser_block, Proc
    property :filters, Array

  end
end
