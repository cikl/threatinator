require 'docile'
require 'threatinator/feed'
require 'threatinator/exceptions'
require 'threatinator/fetchers/http'
require 'threatinator/parsers/getline'
require 'threatinator/parsers/csv'
require 'threatinator/filters/block'
require 'threatinator/filters/whitespace'
require 'threatinator/filters/comments'

module Threatinator
  class FeedBuilder
    def provider(provider_name)
      @provider = provider_name
      self
    end

    def name(name)
      @name = name
      self
    end

    def fetch_http(url, opts = {})
      opts[:url] = url
      @fetcher_builder = lambda do
        opts_dup = Marshal.load(Marshal.dump(opts))
        Threatinator::Fetchers::Http.new(opts_dup)
      end
      self
    end

    def parse_eachline(opts = {}, &block)
      @parser_builder = lambda do
        opts_dup = Marshal.load(Marshal.dump(opts))
        Threatinator::Parsers::Getline.new(opts_dup, &block)
      end
      @parser_block = block
      self
    end

    def parse_csv(opts = {}, &block)
      @parser_builder = lambda do
        opts_dup = Marshal.load(Marshal.dump(opts))
        Threatinator::Parsers::CSVParser.new(opts_dup, &block)
      end
      @parser_block = block
      self
    end

    # Specify a block filter for the parser
    def filter(&block)
      @filter_builders ||= []
      @filter_builders << lambda { Threatinator::Filters::Block.new(block) }
      self
    end

    # Filter out whitespace lines. Only works on line-based text.
    def filter_whitespace
      @filter_builders ||= []
      @filter_builders << lambda { Threatinator::Filters::Whitespace.new }
      self
    end
    
    # Filter out whitespace lines. Only works on line-based text.
    def filter_comments
      @filter_builders ||= []
      @filter_builders << lambda { Threatinator::Filters::Comments.new }
      self
    end

    def build
      Feed.new(
        :provider => @provider, 
        :name => @name,
        :parser_block => @parser_block,
        :fetcher_builder => @fetcher_builder,
        :parser_builder => @parser_builder,
        :filter_builders => @filter_builders,
      )
    end

    # Loads the provided file, and generates a builder from it.
    # @param [String] filename The name of the file to read the feed from
    # @raise [FeedFileNotFoundError] if the file is not found
    def self.from_file(filename)
      begin 
        filedata = File.read(filename)
      rescue Errno::ENOENT
        raise Threatinator::Exceptions::FeedFileNotFoundError.new(filename)
      end
      from_string(filedata, filename, 0)
    end

    # Generates a builder from a string via eval.
    # @param [String] str The DSL code that specifies the feed.
    # @param [String] filename (nil) Passed to eval. 
    # @param [String] lineno (nil) Passed to eval. 
    # @raise [FeedFileNotFoundError] if the file is not found
    # @see Kernel#eval for details on filename and lineno
    def self.from_string(str, filename = nil, lineno = nil)
      from_dsl do
        args = [str, binding]
        unless filename.nil?
          args << filename
          unless lineno.nil?
            args << lineno
          end
        end
        eval(*args)
      end
    end

    # Executes the block parameter within DSL scope
    def self.from_dsl(&block)
      Docile.dsl_eval(self.new, &block)
    end
  end
end

