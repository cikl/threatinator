require 'spec_helper'
require 'threatinator/fetcher'

describe Threatinator::Fetcher do
  let(:fetcher) { Threatinator::Fetcher.new }
  describe "#fetch" do
    it "should raise NotImplementedError because it's not implemented" do
      expect {fetcher.fetch}.to raise_error(NotImplementedError)
    end
  end
end

