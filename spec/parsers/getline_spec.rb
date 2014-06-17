require 'spec_helper'
require 'threatinator/parsers/getline'
require 'stringio'

describe Threatinator::Parsers::Getline do
  it "should default to newline as a separator" do
    str = "line 1\nline 2\nline3!"
    sio = StringIO.new(str)
    parser = described_class.new(sio)

    expect { |b|
      parser.each(&b)
    }.to yield_successive_args("line 1\n", "line 2\n", "line3!")
  end
  it "should let you specify a separator" do
    str = "line 1\0line 2\0line3!"
    sio = StringIO.new(str)
    parser = described_class.new(sio, :separator => "\0")

    expect { |b|
      parser.each(&b)
    }.to yield_successive_args("line 1\0", "line 2\0", "line3!")
  end

  it "shouldn't split anything up if the separator isn't found" do
    str = "line 1\0line 2\0line3!"
    sio = StringIO.new(str)
    parser = described_class.new(sio, :separator => "\n")

    expect { |b|
      parser.each(&b)
    }.to yield_successive_args(str)
  end

  it "should raise an ArgumentError if the separator isn't a single character" do
    sio = StringIO.new()
    expect { described_class.new(sio, :separator => "asdf") }.to raise_error(ArgumentError)
  end

  it "should work on really, really long lines" do
    line1 = ("A" * 100_000) + "\n"
    line2 = ("B" * 100_000) + "\n"
    line3 = "C" * 100_000
    sio = StringIO.new(line1 + line2 + line3)
    parser = described_class.new(sio, :separator => "\n")

    expect { |b|
      parser.each(&b)
    }.to yield_successive_args(line1, line2, line3)
  end
end
