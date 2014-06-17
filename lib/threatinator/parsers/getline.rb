require 'threatinator/parser'
require 'stringio'

module Threatinator
  module Parsers
    # Parses an IO, yielding each 'line' of data as deliniated by :separator.
    # The text matching :separator will be included.
    class Getline < Threatinator::Parser
      READ_SIZE = 10240
      # @param [IO, IOChain] io The IO from which we will read.
      # @param [Hash] opts 
      # @option opts [String] :separator ("\n") A character that will be used
      #  to detect the end of a line.
      def initialize(io, opts = {})
        @io = io
        @separator = opts.delete(:separator) || "\n"
        @buffer = StringIO.new

        unless @separator.length == 1
          raise ArgumentError.new(":separator must be exactly one character long")
        end
        super(opts)
      end

      protected

      def _fill_buffer
        prev_pos = @buffer.pos
        if @buffer.pos != 0
          @buffer.reopen(@buffer.read())
        end
        data = @io.read(READ_SIZE)

        if data.nil?
          # :nocov:
          # read(READ_SIZE) could potentially return nil if @io.eof? is true, 
          # but I don't think it'll ever happen since that's checked for 
          # prior to entering _fill_buffer. I can't get this to happen in
          # testing, but I don't think it'll ever happen, anyway. So, skipping
          # coverage, for now.
          return 0
          # :nocov:
        end

        @buffer.seek(0, IO::SEEK_END)
        @buffer.write(data)
        @buffer.pos = 0
        data.length
      end

      def gets

        loop do
          prev_pos = @buffer.pos
          data = @buffer.gets(@separator)
          if data.nil? or data[-1] != @separator
            # If we're at @io.eof?, then we should return whatever we have,
            # here. 
            return data if @io.eof?

            # If we're here, then we need to read more data onto the end of
            # the buffer.
            @buffer.pos = prev_pos
            _fill_buffer()
            next
          end

          return data
        end

      end

      public

      # @yield [line] Gives one line to the block
      # @yieldparam line [String] a line from the IO stream.
      def each
        return enum_for(:each) unless block_given?
        loop do
          str = gets()
          return if str.nil?
          return if str.empty? && @io.eof && @buffer.eof?
          yield str
        end
        nil
      end
    end
  end
end
