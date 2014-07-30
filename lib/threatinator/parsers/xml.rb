require 'threatinator/parser'
require 'nokogiri'

module Threatinator
  module Parsers
    class XML < Threatinator::Parser
      require 'threatinator/parsers/xml/path'
      require 'threatinator/parsers/xml/record'
      require 'threatinator/parsers/xml/sax_document'

      attr_reader :pattern
      # @param [Hash] opts Parameters hash
      # @option opts [Threatinator::Parsers::XML::Pattern] :pattern The pattern
      #  object to use for matching chunks of XML
      def initialize(opts = {})
        @pattern = opts.delete(:pattern) or raise ArgumentError.new("Missing argument :pattern")
        @max_cursor_depth = @pattern.max_depth - 1
        super(opts)
      end

      def ==(other)
        @pattern == other.pattern && 
          super(other)
      end

      # @param [IO] io
      # @yield [record] Gives one line to the block
      # @yieldparam record [Threatinator::Parser::XML::Record] a record
      def run(io)
        stack = Path.new
        callback = lambda do |element|
          yield(Threatinator::Parsers::XML::Record.new(element))
        end

        doc = SAXDocument.new(@pattern, callback)
        parser = Nokogiri::XML::SAX::Parser.new(doc)
        parser.parse(io)
      end

    end
  end
end



