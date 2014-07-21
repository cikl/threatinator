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
      @fetcher_class = Threatinator::Fetchers::Http
      @fetcher_opts = opts
      self
    end

    def parse_eachline(opts = {}, &block)
      @parser_class = Threatinator::Parsers::Getline
      @parser_opts = opts
      @parser_block = block
      self
    end

    def parse_csv(opts = {}, &block)
      @parser_class = Threatinator::Parsers::CSVParser
      @parser_opts = opts
      @parser_block = block
      self
    end

    # Specify a block filter for the parser
    def filter(&block)
      @filters ||= []
      @filters << Threatinator::Filters::Block.new(block)
      self
    end

    # Filter out whitespace lines. Only works on line-based text.
    def filter_whitespace
      @filters ||= []
      @filters << Threatinator::Filters::Whitespace.new
      self
    end
    
    # Filter out whitespace lines. Only works on line-based text.
    def filter_comments
      @filters ||= []
      @filters << Threatinator::Filters::Comments.new
      self
    end

    def build
      Feed.new(
        :provider => @provider, 
        :name => @name,
        :fetcher_class => @fetcher_class,
        :fetcher_opts => @fetcher_opts,
        :parser_class => @parser_class,
        :parser_opts => @parser_opts,
        :parser_block => @parser_block,
        :filters => @filters || []
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

