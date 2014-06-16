require 'threatinator/parser'

module Threatinator
  module Parsers
    # Parses an IO, yielding each 'line' of data as deliniated by :separator.
    # The text matching :separator will be included.
    class Getline < Threatinator::Parser
      # @param [IO, IOChain] io The IO from which we will read.
      # @param [Hash] opts 
      # @option opts [String] :separator ("\n") A character that will be used
      #  to detect the end of a line.
      def initialize(io, opts = {})
        @io = io
        @separator = opts.delete(:separator) || "\n"

        unless @separator.length == 1
          raise ArgumentError.new(":separator must be exactly one character long")
        end
        super(opts)
      end

      # @yield [line] Gives one line to the block
      # @yieldparam line [String] a line from the IO stream.
      def each
        return enum_for(:each) unless block_given?

        buffer = ""
        while char = @io.read(1)
          buffer << char

          if buffer.end_with?(@separator)
            yield buffer
            buffer = ""
          end
        end

        if buffer.length > 0
          # Emit the last line before returning.
          yield buffer
        end
        nil
      end
    end
  end
end
