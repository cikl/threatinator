require 'spec_helper'
require 'threatinator/parsers/json/parser'
require 'stringio'
require 'multi_json'

describe Threatinator::Parsers::JSON::Parser do
  it_should_behave_like "a parser when compared to an identically configured parser" do
    let(:parser1) { described_class.new() }
    let(:parser2) { described_class.new() }
  end

  let(:element1) { 
    { 
      'id' => 1,
      'marbles' => [
        { 'color' => 'red', 'count' => 20 },
        { 'color' => 'blue', 'count' => 15 }
      ],
      'owner' => { 'name' => 'Billy', 'age' => '6' }
    }
  }
  let(:element2) { 
    { 
      'id' => 2,
      'marbles' => [
        { 'color' => 'red', 'count' => 3 },
        { 'color' => 'green', 'count' => 37 }
      ],
      'owner' => { 'name' => 'Sarah', 'age' => '7' }
    }
  }
  let(:element3) {
    { 
      'id' => 3,
      'marbles' => [
        { 'color' => 'purple', 'count' => 73 }
      ],
      'owner' => { 'name' => 'Phil', 'age' => '5' }
    }
  }

  context "when parsing a JSON string whose root element is an Array" do
    let(:json_string) { MultiJson.dump([element1, element2, element3]) }
    let(:io) { StringIO.new(json_string) }

    it "should yield each of the array's elements as the :data of a Parsers::JSON::Record" do
      parser = described_class.new()

      expect { |b|
        parser.run(io, &b)
      }.to yield_successive_args(
        Threatinator::Parsers::JSON::Record.new(element1), 
        Threatinator::Parsers::JSON::Record.new(element2), 
        Threatinator::Parsers::JSON::Record.new(element3)
      )
    end
  end

  context "when parsing a JSON string whose root element is a Hash" do
    let(:json_string) { MultiJson.dump({'foo' => element1, 'bar' => element2, 'bla' => element3}) }
    let(:io) { StringIO.new(json_string) }

    it "should yield each of the hash's key/value pairs as the :key and :data of a Parsers::JSON::Record" do
      parser = described_class.new()

      expect { |b|
        parser.run(io, &b)
      }.to yield_successive_args(
        Threatinator::Parsers::JSON::Record.new(element1, key: 'foo'), 
        Threatinator::Parsers::JSON::Record.new(element2, key: 'bar'), 
        Threatinator::Parsers::JSON::Record.new(element3, key: 'bla')
      )
    end
  end

  context "when parsing something that is not JSON data" do
    let(:json_string) { "hi there! this is my data feed" }
    let(:io) { StringIO.new(json_string) }

    it "should raise a exception Threatinator::Exceptions::ParseError" do
      parser = described_class.new()

      expect { |b|
        parser.run(io, &b)
      }.to raise_error(Threatinator::Exceptions::ParseError)
    end
  end

  context "when parsing a JSON that is truncated" do
    let(:json_string) { MultiJson.dump({'foo' => element1, 'bar' => element2, 'bla' => element3})[0..-3] }
    let(:io) { StringIO.new(json_string) }

    it "should yield as many records as possible before raising a ParseError" do
      parser = described_class.new()

      expect { |b|
        expect {
          parser.run(io, &b)
        }.to raise_error(Threatinator::Exceptions::ParseError)
      }.to yield_successive_args(
        Threatinator::Parsers::JSON::Record.new(element1, key: 'foo'), 
        Threatinator::Parsers::JSON::Record.new(element2, key: 'bar')
      )
    end
  end
end
