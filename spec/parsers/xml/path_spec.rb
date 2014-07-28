require 'spec_helper'
require 'threatinator/parsers/xml/path'

describe Threatinator::Parsers::XML::Path do

  describe 'initializing' do
    context "with str_or_parts not set" do
      let (:path) { described_class.new() }
      describe "#parts" do
        specify "returns an empty array" do
          expect(path.parts).to eq([])
        end
      end
    end

    context "with str_or_parts set to a String" do
      let (:path) { described_class.new('/a/b/c') }
      describe "#parts" do
        specify "returns the string split by '/'" do
          expect(path.parts).to eq(['a', 'b', 'c'])
        end
      end
      it "raises ArgumentError when the string doesn't begin with '/'" do
        expect {
          described_class.new("a/b/c")
        }.to raise_error(ArgumentError)
      end
      it "raises ArgumentError when the string is empty" do
        expect {
          described_class.new("")
        }.to raise_error(ArgumentError)
      end
    end

    context "with str_or_parts set to nil" do
      let (:path) { described_class.new(nil) }
      describe "#parts" do
        specify "returns an empty array" do
          expect(path.parts).to eq([])
        end
      end
    end

    context "with str_or_parts set to an array" do
      let(:array) { ['a', 'b', 'c'] }
      let(:path) { described_class.new(array) }
      describe "#parts" do
        specify "returns an array that =='s the original array" do
          expect(path.parts).to eq(array)
        end
        specify "returns a different array instance than the original array" do
          expect(path.parts).not_to equal(array)
        end
      end
    end

    it "raises TypeError when path_or_str is set to something other than a String, Array, or nil" do
      expect {
        described_class.new(1234)
      }.to raise_error(TypeError)
    end
  end

  describe "#==" do
    it "returns true when testing against itself" do
      path = described_class.new('/a/b/c')
      expect(path).to be == path
    end
    it "returns true when testing another path with the same parts" do
      path = described_class.new('/a/b/c')
      path2 = described_class.new(['a', 'b', 'c'])
      expect(path).to be == path2
    end
    it "returns true when testing an object that responds to #parts with the same values" do
      path = described_class.new('/a/b/c')
      object = Class.new do
        def parts
          ['a', 'b', 'c']
        end
      end.new
      expect(path).to be == object
    end
    it "returns false when testing an object that responds to #parts with different values" do
      path = described_class.new('/a/b/c')
      object = Class.new do
        def parts
          ['a', 'b', 'c', 'd']
        end
      end.new
      expect(path).not_to be == object
    end
    it "returns false when testing against another path with different parts" do
      path = described_class.new('/a/b/c')
      path2 = described_class.new('/a/b/c/e')
      expect(path).not_to be == path2
    end
  end

  describe "#eql?" do
    it "returns true when testing against itself" do
      path = described_class.new('/a/b/c')
      expect(path).to eql path
    end
    it "returns true when testing another path with the same parts" do
      path = described_class.new('/a/b/c')
      path2 = described_class.new(['a', 'b', 'c'])
      expect(path).to eql path2
    end
    it "returns false when testing against another path with different parts" do
      path = described_class.new('/a/b/c')
      path2 = described_class.new('/a/b/c/e')
      expect(path).not_to eql path2
    end
    it "returns false when testing an object that responds to #parts with the same values" do
      path = described_class.new('/a/b/c')
      object = Class.new do
        def parts
          ['a', 'b', 'c']
        end
      end.new
      expect(path).not_to eql object
    end
    it "returns false when testing against something that is not a Path" do
      path = described_class.new('/a/b/c')
      path2 = "hi there"
      expect(path).not_to eql path2
    end
  end

  describe "#end_with?" do
    let(:path) { described_class.new('/a/b/c') }

    it "returns true when testing against itself" do
      expect(path.end_with?(path)).to eq(true)
    end
    it "returns true when testing against an identical path" do
      path2 = described_class.new('/a/b/c')
      expect(path.end_with?(path2)).to eq(true)
    end

    it "returns true when tested against any path that it happens to end with" do
      expect(path.end_with?(described_class.new('/b/c'))).to eq(true)
      expect(path.end_with?(described_class.new('/c'))).to eq(true)
    end

    it "returns true when tested against a path with no length" do
      expect(path.end_with?(described_class.new('/'))).to eq(true)
    end

    it "returns false when tested against a path that is longer than itself" do
      expect(path.end_with?(described_class.new('/a/a/b/c'))).to eq(false)
    end

    it "returns false when tested against a path it does not end with" do
      expect(path.end_with?(described_class.new('/a'))).to eq(false)
      expect(path.end_with?(described_class.new('/a/b'))).to eq(false)
      expect(path.end_with?(described_class.new('/b'))).to eq(false)
    end
  end

  describe "#push" do
    let(:path) { described_class.new }
    it "adds a new entry to the end of the #parts" do
      path.push('a')
      expect(path.parts).to eq(['a'])
      path.push('b')
      expect(path.parts).to eq(['a', 'b'])
      path.push('c')
      expect(path.parts).to eq(['a', 'b', 'c'])
    end
  end

  describe "#pop" do
    let(:path) { described_class.new('/a/b/c') }
    it "appends a new entry to the end of the #parts" do
      expect(path.parts).to eq(['a', 'b', 'c'])
      path.pop()
      expect(path.parts).to eq(['a', 'b'])
      path.pop()
      expect(path.parts).to eq(['a'])
      path.pop()
      expect(path.parts).to eq([])
    end

    it "returns the value popped off the end of the parts" do
      expect(path.pop()).to eq('c')
      expect(path.pop()).to eq('b')
      expect(path.pop()).to eq('a')
    end

    it "returns nil if there are no parts" do
      path.pop(); path.pop(); path.pop();
      expect(path.pop()).to be_nil
    end
  end

  describe "#length" do
    let(:path) { described_class.new('/a/b/c') }
    it "returns the number of parts" do
      expect(path.length).to eq(3)
      10.times { path.push('Z') }
      expect(path.length).to eq(13)
      20.times { path.pop() }
      expect(path.length).to eq(0)
    end
  end
end


