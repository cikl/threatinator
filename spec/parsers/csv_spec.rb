require 'spec_helper'
require 'threatinator/parsers/csv'
require 'stringio'
require 'threatinator/record'

describe Threatinator::Parsers::CSVParser do
  context "by default" do
    it "should parse \\n as a row separator" do
      str = "abc\ndef\nhij"
      sio = StringIO.new(str)
      parser = described_class.new(sio)

      expect { |b|
        parser.each(&b)
      }.to yield_successive_args(
        Threatinator::Record.new(['abc'], line_number: 1, pos_start: 0, pos_end: 4), 
        Threatinator::Record.new(['def'], line_number: 2, pos_start: 4, pos_end: 8), 
        Threatinator::Record.new(['hij'], line_number: 3, pos_start: 8, pos_end: 11), 
      )
    end

    it "should parse \\r\\n as a row separator"  do
      str = "abc\r\ndef\r\nhij"
      sio = StringIO.new(str)
      parser = described_class.new(sio)

      expect { |b|
        parser.each(&b)
      }.to yield_successive_args(
        Threatinator::Record.new(['abc'], line_number: 1, pos_start: 0, pos_end: 5), 
        Threatinator::Record.new(['def'], line_number: 2, pos_start: 5, pos_end: 10), 
        Threatinator::Record.new(['hij'], line_number: 3, pos_start: 10, pos_end: 13), 
      )
    end

    it "should parse \\r as a row separator"  do
      str = "abc\rdef\rhij"
      sio = StringIO.new(str)
      parser = described_class.new(sio)

      expect { |b|
        parser.each(&b)
      }.to yield_successive_args(
        Threatinator::Record.new(['abc'], line_number: 1, pos_start: 0, pos_end: 4), 
        Threatinator::Record.new(['def'], line_number: 2, pos_start: 4, pos_end: 8), 
        Threatinator::Record.new(['hij'], line_number: 3, pos_start: 8, pos_end: 11), 
      )
    end

    it "should use commas as column separators" do
      str = "1,2,3\n4,5,6\n7,8,9"
      sio = StringIO.new(str)
      parser = described_class.new(sio)

      expect { |b|
        parser.each(&b)
      }.to yield_successive_args(
        Threatinator::Record.new(['1','2','3'], line_number: 1, pos_start: 0, pos_end: 6), 
        Threatinator::Record.new(['4','5','6'], line_number: 2, pos_start: 6, pos_end: 12), 
        Threatinator::Record.new(['7','8','9'], line_number: 3, pos_start: 12, pos_end: 17), 
      )
    end

    it "should ignore separators contained in between a set of double-quotes" do
      str = "1,\"2\",3\n\"4,5\",6\n\"7,8,9\""
      sio = StringIO.new(str)
      parser = described_class.new(sio)

      expect { |b|
        parser.each(&b)
      }.to yield_successive_args(
        Threatinator::Record.new(['1','2','3'], line_number: 1, pos_start: 0, pos_end: 8), 
        Threatinator::Record.new(['4,5','6'], line_number: 2, pos_start: 8, pos_end: 16), 
        Threatinator::Record.new(['7,8,9'], line_number: 3, pos_start: 16, pos_end: 23), 
      )
    end
  end

  describe "configuration options" do
    describe ":row_separator" do
      it "should specify the row separator" do
        str = "1,2,3X4,5,6X7,8,9"
        sio = StringIO.new(str)
        parser = described_class.new(sio, row_separator: "X")

        expect { |b|
          parser.each(&b)
        }.to yield_successive_args(
          Threatinator::Record.new(['1','2','3'], line_number: 1, pos_start: 0, pos_end: 6), 
          Threatinator::Record.new(['4','5','6'], line_number: 2, pos_start: 6, pos_end: 12), 
          Threatinator::Record.new(['7','8','9'], line_number: 3, pos_start: 12, pos_end: 17), 
        )
      end
    end

    describe ":col_separator" do
      it "should specify the column separator" do
        str = "1X2X3\n4X5X6\n7X8X9"
        sio = StringIO.new(str)
        parser = described_class.new(sio, col_separator: "X")

        expect { |b|
          parser.each(&b)
        }.to yield_successive_args(
          Threatinator::Record.new(['1','2','3'], line_number: 1, pos_start: 0, pos_end: 6), 
          Threatinator::Record.new(['4','5','6'], line_number: 2, pos_start: 6, pos_end: 12), 
          Threatinator::Record.new(['7','8','9'], line_number: 3, pos_start: 12, pos_end: 17), 
        )
      end
    end
    describe ":headers" do
      context "when set to false" do
        it "should not use any headers" do 
          str = "1,2,3\n4,5,6\n7,8,9"
          sio = StringIO.new(str)
          parser = described_class.new(sio, headers: false)

          expect { |b|
            parser.each(&b)
          }.to yield_successive_args(
            Threatinator::Record.new(['1','2','3'], line_number: 1, pos_start: 0, pos_end: 6), 
            Threatinator::Record.new(['4','5','6'], line_number: 2, pos_start: 6, pos_end: 12), 
            Threatinator::Record.new(['7','8','9'], line_number: 3, pos_start: 12, pos_end: 17), 
          )
        end
      end
      context "when set to true" do
        it "should read the first row as the headers, returning Hashes with the headers as keys" do

          str = "a,b,c\n1,2,3\n4,5,6\n7,8,9"
          sio = StringIO.new(str)
          parser = described_class.new(sio, headers: true)

          expect { |b|
            parser.each(&b)
          }.to yield_successive_args(
            Threatinator::Record.new({'a'=>'1','b'=>'2','c'=>'3'}, line_number: 2, pos_start: 6, pos_end: 12), 
            Threatinator::Record.new({'a'=>'4','b'=>'5','c'=>'6'}, line_number: 3, pos_start: 12, pos_end: 18), 
            Threatinator::Record.new({'a'=>'7','b'=>'8','c'=>'9'}, line_number: 4, pos_start: 18, pos_end: 23) 
          )
        end
      end
      context "when set to :first_row" do
        it "should read the first row as the headers, returning Hashes with the headers as keys" do

          str = "a,b,c\n1,2,3\n4,5,6\n7,8,9"
          sio = StringIO.new(str)
          parser = described_class.new(sio, headers: :first_row)

          expect { |b|
            parser.each(&b)
          }.to yield_successive_args(
            Threatinator::Record.new({'a'=>'1','b'=>'2','c'=>'3'}, line_number: 2, pos_start: 6, pos_end: 12), 
            Threatinator::Record.new({'a'=>'4','b'=>'5','c'=>'6'}, line_number: 3, pos_start: 12, pos_end: 18), 
            Threatinator::Record.new({'a'=>'7','b'=>'8','c'=>'9'}, line_number: 4, pos_start: 18, pos_end: 23) 
          )
        end
      end
      context "when set to an array of strings" do
        it "should use the array as the headers, returning Hashes with the headers as keys" do

          str = "1,2,3\n4,5,6\n7,8,9"
          sio = StringIO.new(str)
          parser = described_class.new(sio, headers: ['a', 'b', 'c'])

          expect { |b|
            parser.each(&b)
          }.to yield_successive_args(
            Threatinator::Record.new({'a'=>'1','b'=>'2','c'=>'3'}, line_number: 2, pos_start: 0, pos_end: 6), 
            Threatinator::Record.new({'a'=>'4','b'=>'5','c'=>'6'}, line_number: 3, pos_start: 6, pos_end: 12), 
            Threatinator::Record.new({'a'=>'7','b'=>'8','c'=>'9'}, line_number: 4, pos_start: 12, pos_end: 17) 
          )
        end
      end
    end
  end
end

