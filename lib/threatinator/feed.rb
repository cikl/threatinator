require 'threatinator/exceptions'

module Threatinator
  class Feed

    def initialize(opts = {})
      @provider = opts.delete(:provider)
      @name = opts.delete(:name)
      @fetcher_class = opts.delete(:fetcher_class)
      @fetcher_opts = opts.delete(:fetcher_opts) || {}
      @parser_class = opts.delete(:parser_class)
      @parser_opts = opts.delete(:parser_opts) || {}
      @parser_block = opts.delete(:parser_block)
      @filters = opts.delete(:filters) || []
      validate!
    end

    def provider
      @provider.dup
    end

    def name
      @name.dup
    end

    def fetcher_class
      @fetcher_class
    end

    def fetcher_opts
      Marshal.load(Marshal.dump(@fetcher_opts))
    end

    def parser_class
      @parser_class
    end

    def parser_opts
      Marshal.load(Marshal.dump(@parser_opts))
    end

    def parser_block
      @parser_block
    end

    def filters
      @filters.dup
    end

    def validate!
      validate_attribute!(:provider, @provider, ::String)
      validate_attribute!(:name, @name, ::String)
      validate_attribute!(:fetcher_class, @fetcher_class, ::Class)
      validate_attribute!(:fetcher_opts, @fetcher_opts, ::Hash)
      validate_attribute!(:parser_class, @parser_class, ::Class)
      validate_attribute!(:parser_opts, @parser_opts, ::Hash)
      validate_attribute!(:parser_block, @parser_block, ::Proc)
      validate_attribute!(:filters, @filters, ::Array)
    end

    def validate_attribute!(name, val, type)
      unless val.kind_of?(type)
        raise Threatinator::Exceptions::InvalidAttributeError.new(name, val)
      end
    end
  end
end
