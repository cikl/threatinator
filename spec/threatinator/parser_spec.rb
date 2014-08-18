require 'spec_helper'
require 'threatinator/parser'

describe Threatinator::Parser do
  let(:parser) { Threatinator::Parser.new() }
  describe "#run" do
    it "should raise NotImplementedError because it's not implemented" do
      expect { |b| parser.run(double("io"), &b) }.to raise_error(NotImplementedError)
    end
  end
end


