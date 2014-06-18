require 'spec_helper'
require 'threatinator/filter'

describe Threatinator::Filter do
  let(:filter) { Threatinator::Filter.new }
  describe "#filter?(*args)" do
    it "should raise NotImplementedError because it's not implemented" do
      expect {filter.filter?(1234)}.to raise_error(NotImplementedError)
    end
  end
end


