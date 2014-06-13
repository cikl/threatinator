require 'spec_helper'
require 'threatinator/io_wrapper'

describe Threatinator::IOWrapper do

  describe :wrap do
    it "should return an IOWrapper for the IO object" do
      r, w = IO.pipe()
      io_wrapper = Threatinator::IOWrapper.wrap(r)
      expect(io_wrapper).to be_kind_of(Threatinator::IOWrapper)
      r.close
      w.close
    end
  end

  it_should_behave_like "an iowrapper"

  context "wrapping an IOWrapper" do
  end
end
