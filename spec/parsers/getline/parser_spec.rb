require 'spec_helper'
require 'threatinator/parsers/getline/parser'
require 'stringio'
require 'threatinator/record'

describe Threatinator::Parsers::Getline::Parser do
  it_should_behave_like "a parser when compared to an identically configured parser" do
    let(:parser1) { described_class.new(:separator => "X") }
    let(:parser2) { described_class.new(:separator => "X") }
  end
  
  context "two instances with differently configured separators" do
    it_should_behave_like "a parser when compared to a differently configured parser" do
      let(:parser1) { described_class.new(:separator => "X") }
      let(:parser2) { described_class.new(:separator => "Y") }
    end
  end

  it "should default to newline as a separator" do
    str = "line 1\nline 2\nline3!"
    sio = StringIO.new(str)
    parser = described_class.new()

    expect { |b|
      parser.run(sio, &b)
    }.to yield_successive_args(
      Threatinator::Record.new("line 1\n", line_number: 1, pos_start: 0, pos_end: 7), 
      Threatinator::Record.new("line 2\n", line_number: 2, pos_start: 7, pos_end: 14), 
      Threatinator::Record.new("line3!", line_number: 3, pos_start: 14, pos_end: 20)
    )
  end
  describe ":separator" do
    it "should be accessible via the #separator method" do
      parser = described_class.new(:separator => "Z")
      expect(parser.separator).to eq("Z")
    end
    it "should specify a separator" do
      str = "line 1\0line 2\0line3!"
      sio = StringIO.new(str)
      parser = described_class.new(:separator => "\0")

      expect { |b|
        parser.run(sio, &b)
      }.to yield_successive_args(
        Threatinator::Record.new("line 1\0", line_number: 1, pos_start: 0, pos_end: 7), 
        Threatinator::Record.new("line 2\0", line_number: 2, pos_start: 7, pos_end: 14), 
        Threatinator::Record.new("line3!", line_number: 3, pos_start: 14, pos_end: 20)
      )
    end
  end

  it "shouldn't split anything up if the separator isn't found" do
    str = "line 1\0line 2\0line3!"
    sio = StringIO.new(str)
    parser = described_class.new(:separator => "\n")

    expect { |b|
      parser.run(sio, &b)
    }.to yield_successive_args(
      Threatinator::Record.new("line 1\0line 2\0line3!", line_number: 1, pos_start: 0, pos_end: 20) 
)
  end

  it "should raise an ArgumentError if the separator isn't a single character" do
    sio = StringIO.new()
    expect { described_class.new(:separator => "asdf") }.to raise_error(ArgumentError)
  end

  it "should work on really, really long lines" do
    line1 = ("A" * 100_000) + "\n"
    line2 = ("B" * 100_000) + "\n"
    line3 = "C" * 100_000
    record1 = Threatinator::Record.new(line1, :line_number => 1, :pos_start => 0, :pos_end => 100_001)
    record2 = Threatinator::Record.new(line2, :line_number => 2, :pos_start => 100_001, :pos_end => 200_002)
    record3 = Threatinator::Record.new(line3, :line_number => 3, :pos_start => 200_002, :pos_end => 300_002)
    sio = StringIO.new(line1 + line2 + line3)
    parser = described_class.new(:separator => "\n")

    expect { |b|
      parser.run(sio, &b)
    }.to yield_successive_args(record1, record2, record3)
  end
end
