require 'threatinator/record'
require 'threatinator/parser'
require 'stringio'

module Threatinator
  module Parsers
    # Parses an IO, yielding each 'line' of data as deliniated by :separator.
    # The text matching :separator will be included.
    class Getline < Threatinator::Parser
      READ_SIZE = 10240
      # @param [IO] io The IO from which we will read.
      # @param [Hash] opts 
      # @option opts [String] :separator ("\n") A character that will be used
      #  to detect the end of a line.
      def initialize(io, opts = {})
        @separator = opts.delete(:separator) || "\n"
        unless @separator.length == 1
          raise ArgumentError.new(":separator must be exactly one character long")
        end
        super(io, opts)
      end

      # @yield [line] Gives one line to the block
      # @yieldparam line [String] a line from the IO stream.
      def each
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
