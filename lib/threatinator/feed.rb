require 'threatinator/exceptions'

module Threatinator
  class Feed
    # @param [Hash] opts Options hash
    # @option opts [String] :provider The name of the provider
    # @option opts [String] :name The name of the feed
    # @option opts [Proc] :parser_block A block that will be called by the 
    #   parser each time it processes a record.
    # @option opts [Proc] :parser_builder A proc that, when called, will 
    #   return a brand new instance of a Threatinator::Parser.
    # @option opts [Proc] :fetcher_builder A proc that, when called, will 
    #   return a brand new instance of a Threatinator::Fetcher.
    # @option opts [Array<Proc>] :filter_builders An array of procs that, 
    #   when called, will each return an instance of a filter (something that 
    #   responds to :filter?)
    # @option opts [Array<Proc>] :decoder_builders An array of procs that, 
    #   when called, will each return an instance of a Threatinator::Decoder
    def initialize(opts = {})
      @provider = opts.delete(:provider)
      @name = opts.delete(:name)
      @parser_block = opts.delete(:parser_block)

      @parser_builder = opts.delete(:parser_builder)
      @fetcher_builder = opts.delete(:fetcher_builder)
      @filter_builders = opts.delete(:filter_builders) || []
      @decoder_builders = opts.delete(:decoder_builders) || []
      validate!
    end

    def provider
      @provider.dup
    end

    def name
      @name.dup
    end

    def parser_block
      @parser_block
    end

    def fetcher_builder
      @fetcher_builder
    end

    def parser_builder
      @parser_builder
    end

    def filter_builders
      @filter_builders.dup
    end

    def decoder_builders
      @decoder_builders.dup
    end

    def validate!
      validate_attribute!(:provider, @provider) { |x| x.kind_of?(::String) }
      validate_attribute!(:name, @name) { |x| x.kind_of?(::String) }
      validate_attribute!(:parser_block, @parser_block) { |x| x.kind_of?(::Proc) }
      validate_attribute!(:fetcher_builder, @fetcher_builder) { |x| x.kind_of?(::Proc) }
      validate_attribute!(:parser_builder, @parser_builder) { |x| x.kind_of?(::Proc) }
      validate_attribute!(:filter_builders, @filter_builders) do |x|
        x.kind_of?(::Array) &&
          x.all? { |e| e.kind_of?(::Proc) }
      end

      validate_attribute!(:decoder_builders, @decoder_builders) do |x|
        x.kind_of?(::Array) &&
          x.all? { |e| e.kind_of?(::Proc) }
      end
    end

    def validate_attribute!(name, val, &block)
      unless block.call(val) == true
        raise Threatinator::Exceptions::InvalidAttributeError.new("Invalid attribute (#{name}). Got: #{val.inspect}")
      end
    end
  end
end
