require 'spec_helper'
require 'threatinator/parser'

describe Threatinator::Parser do
  let(:parser) { Threatinator::Parser.new }
  describe "#parser" do
    it "should raise NotImplementedError because it's not implemented" do
      expect { |b| parser.each(&b) }.to raise_error(NotImplementedError)
    end
  end
end


