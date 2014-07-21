require 'threatinator/record'
require 'threatinator/parser'
require 'csv'

module Threatinator
  module Parsers
    # Parses an IO, yielding a record with a CSV::Row.
    class CSVParser < Threatinator::Parser
      # @param [IO] io The IO from which we will read.
      # @param [Hash] opts 
      # @option opts [String, :auto] :row_separator A string that represent the row
      #  separator. Identical to ::CSV.new's :row_sep.
      # @option opts [String] :col_separator A string that represents the column
      #  separator. Identical to ::CSV.new's :col_sep.
      # @option opts [Array<String>, :first_row, true, false] :headers The header
      #  configuration. Identical to ::CSV.new's :headers. 
      # @option opts [Hash] :csv_opts A hash of options that will be passed to
      #  Ruby's CSV.new. 
      # @see ::CSV
      def initialize(io, opts = {})
        @csv_opts = {}.merge(opts.delete(:csv_opts) || {})
        @csv_opts[:return_headers] = true
        @csv_opts[:row_sep] = opts.delete(:row_separator) if opts.has_key?(:row_separator)
        @csv_opts[:col_sep] = opts.delete(:col_separator) if opts.has_key?(:col_separator)
        @csv_opts[:headers] = opts.delete(:headers) if opts.has_key?(:headers)

        super(io, opts)
      end

      # @yield [record] Gives one line to the block
      # @yieldparam record [Record] a record
      def each
        return enum_for(:each) unless block_given?
        lineno = 1
        previous_pos = io.pos
        csv = ::CSV.new(io, @csv_opts)
        csv.each do |row|
          begin
            if row.kind_of?(::CSV::Row)
              next if row.header_row?
              row = row.to_hash
            end

            yield Record.new(row, 
                             line_number: lineno, 
                             pos_start: previous_pos, 
                             pos_end: io.pos)

          ensure
            previous_pos = io.pos
            lineno += 1
          end
        end
        nil
      end
    end
  end
end

