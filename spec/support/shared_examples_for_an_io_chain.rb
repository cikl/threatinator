require 'spec_helper'

shared_examples_for "an io chain" do
  describe "#read" do
    subject { chain.read() }
    it {should eq(expected_data) }
  end

  describe "#close" do
    it "should close the chain" do
      expect(chain).not_to be_closed
      chain.close
      expect(chain).to be_closed
    end
  end

  describe "#closed?" do
    it "should return true if the chain is closed" do
      chain.close
      expect(chain).to be_closed
    end
    it "should return false if the chain is not closed" do
      expect(chain).not_to be_closed
    end
  end
end

