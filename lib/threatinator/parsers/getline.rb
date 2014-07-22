require 'threatinator/record'
require 'threatinator/parser'

module Threatinator
  module Parsers
    # Parses an IO, yielding each 'line' of data as deliniated by :separator.
    # The text matching :separator will be included.
    class Getline < Threatinator::Parser
      attr_reader :separator

      # @param [Hash] opts 
      # @option opts [String] :separator ("\n") A character that will be used
      #  to detect the end of a line.
      def initialize(opts = {})
        @separator = opts.delete(:separator) || "\n"
        unless @separator.length == 1
          raise ArgumentError.new(":separator must be exactly one character long")
        end
        super(opts)
      end

      def ==(other)
        @separator == other.separator &&
          super(other)
      end

      # @param [IO] io The IO to be parsed
      # @yield [line] Gives one line to the block
      # @yieldparam line [String] a line from the IO stream.
      def run(io)
        return enum_for(:each) unless block_given?
        lineno = 1
        while str = io.gets(@separator)
          return if str.nil?
          pos_start = io.pos - str.length
          yield Record.new(str, line_number: lineno, pos_start: pos_start, pos_end: io.pos)
          lineno += 1
        end
        nil
      end
    end
  end
end
