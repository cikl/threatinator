require 'spec_helper'
require 'threatinator/parsers/xml/pattern'

describe Threatinator::Parsers::XML::Pattern do

  context "when initialized with" do
    let(:pattern) { described_class.new(pathspec) }

    context "pathspec: '/a/b/c'" do
      let(:pathspec) { '/a/b/c' }
      describe "#max_depth" do
        it "returns 3" do
          expect(pattern.max_depth).to eq(3)
        end
      end
      describe "#match?" do
        it "returns true for the path '/a/b/c'" do
          path = Threatinator::Parsers::XML::Path.new('/a/b/c')
          expect(pattern.match?(path)).to eq(true)
        end
        it "returns false for the path '/a/b/c/d'" do
          path = Threatinator::Parsers::XML::Path.new('/a/b/c/d')
          expect(pattern.match?(path)).to eq(false)
        end
        it "returns false for the path '/a/b/cd'" do
          path = Threatinator::Parsers::XML::Path.new('/a/b/cd')
          expect(pattern.match?(path)).to eq(false)
        end
        it "returns false for the path '/a/b'" do
          path = Threatinator::Parsers::XML::Path.new('/a/b')
          expect(pattern.match?(path)).to eq(false)
        end
      end
    end

    context "pathspec: '//b/c'" do
      let(:pathspec) { '//b/c' }
      describe "#max_depth" do
        it "returns Infinity" do
          expect(pattern.max_depth).to eq(Float::INFINITY)
        end
      end
      describe "#match?" do
        it "returns true for the path '/a/b/c'" do
          path = Threatinator::Parsers::XML::Path.new('/a/b/c')
          expect(pattern.match?(path)).to eq(true)
        end
        it "returns true for the path '/b/c'" do
          path = Threatinator::Parsers::XML::Path.new('/b/c')
          expect(pattern.match?(path)).to eq(true)
        end
        it "returns true for the path '/a/a/a/a/a/a/a/a/b/c'" do
          path = Threatinator::Parsers::XML::Path.new('/a/a/a/a/a/a/a/a/b/c')
          expect(pattern.match?(path)).to eq(true)
        end
        it "returns false for the path '/a/b'" do
          path = Threatinator::Parsers::XML::Path.new('/a/b')
          expect(pattern.match?(path)).to eq(false)
        end
      end
    end

    context "pathspec: '///c'" do
      let(:pathspec) { '///c' }
      it "should raise an ArgumentError" do
        expect {
          pattern
        }.to raise_error(ArgumentError)
      end
    end
  end
end
