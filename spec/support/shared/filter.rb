require 'spec_helper'

shared_examples_for "a filter" do
  # expects :filter, :should_filter, and :shouldnt_filter

  describe "#filter?" do
    it "should return true for data that is meant to be filtered" do
      expect(filter.filter?(should_filter)).to eq(true)
    end
    it "should return false for data that is meant to be filtered" do
      expect(filter.filter?(shouldnt_filter)).to eq(false)
    end
  end
end
