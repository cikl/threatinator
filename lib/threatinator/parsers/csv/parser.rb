require 'threatinator/record'
require 'threatinator/parser'
require 'csv'

module Threatinator
  module Parsers
    module CSV
      # Parses an IO, yielding a record with a CSV::Row.
      class Parser < Threatinator::Parser
        attr_reader :csv_opts, :row_separator, :col_separator, :headers

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
        def initialize(opts = {})
          @csv_opts = {}.merge(opts.delete(:csv_opts) || {})
          @row_separator = opts.delete(:row_separator)
          @col_separator = opts.delete(:col_separator)
          @headers = opts.delete(:headers)

          super(opts)
        end

        def ==(other)
          @csv_opts == other.csv_opts &&
            @row_separator == other.row_separator &&
            @col_separator == other.col_separator &&
            @headers == other.headers &&
            super(other)
        end

        def _build_csv_opts
          opts = {}.merge(@csv_opts)
          opts[:return_headers] = true
          opts[:row_sep] = @row_separator unless @row_separator.nil?
          opts[:col_sep] = @col_separator unless @col_separator.nil?
          opts[:headers] = @headers unless @headers.nil?
          opts
        end

        # @param [IO] io
        # @yield [record] Gives one line to the block
        # @yieldparam record [Record] a record
        def run(io)
          lineno = 1
          previous_pos = io.pos
          csv = ::CSV.new(io, _build_csv_opts())
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
end
